terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.7.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.cluster_name}-rg"
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.cluster_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  for_each            = toset(var.machines)
  name                = "${var.cluster_name}-${each.key}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  for_each            = toset(var.machines)
  name                = "${var.cluster_name}-${each.key}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "null_resource" "reboot-when-ignition-changes" {
  for_each = toset(var.machines)
  triggers = {
    ignition_config = data.ct_config.machine-ignitions[each.key].rendered
  }
  # Wait for the new Ignition config object to be ready before rebooting
  depends_on = [azurerm_storage_blob.object]
  # Trigger running Ignition on the next reboot and reboot the instance (current limitation: also runs on the first provisioning)
  provisioner "local-exec" {
    command = "while ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${azurerm_linux_virtual_machine.machine[each.key].public_ip_address} \"sudo /usr/share/oem/reprovision '${azurerm_storage_blob.object[each.key].url}${data.azurerm_storage_account_blob_container_sas.ignition.sas}'\" ; do sleep 1; done; while ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${azurerm_linux_virtual_machine.machine[each.key].public_ip_address} sudo systemctl reboot; do sleep 1; done"
  }
}

resource "azurerm_storage_account" "ignition" {
  name                     = replace(lower(var.cluster_name), "/[^[:alnum:]]/", "")
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "user-data-forcenew-workaround" {
  name                  = "user-data-forcenew-workaround-${var.cluster_name}"
  storage_account_name  = azurerm_storage_account.ignition.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "ignition" {
  connection_string = azurerm_storage_account.ignition.primary_connection_string
  container_name    = azurerm_storage_container.user-data-forcenew-workaround.name
  https_only        = true

  start  = "2021-01-01"
  expiry = "2099-01-01"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }

  content_type = "application/json"
}

# Ignition config, privately accessible
resource "azurerm_storage_blob" "object" {
  for_each               = toset(var.machines)
  name                   = "${var.cluster_name}-${each.key}"
  storage_account_name   = azurerm_storage_account.ignition.name
  storage_container_name = azurerm_storage_container.user-data-forcenew-workaround.name
  type                   = "Block"
  source_content         = data.ct_config.machine-ignitions[each.key].rendered
}

resource "azurerm_linux_virtual_machine" "machine" {
  for_each            = toset(var.machines)
  name                = "${var.cluster_name}-${each.key}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.server_type
  admin_username      = "core"

  lifecycle {
    ignore_changes = [custom_data]
  }

  # Workaround: Indirection through blob storage because "lifecycle { ignore_changes = [user_data] }" is not flexible enough to keep the instance while still updating the user data
  custom_data         = base64encode("{ \"ignition\": { \"version\": \"2.1.0\", \"config\": { \"replace\": { \"source\": \"${azurerm_storage_blob.object[each.key].url}${data.azurerm_storage_account_blob_container_sas.ignition.sas}\" } } } }")
  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
  ]

  admin_ssh_key {
    username   = "core"
    public_key = var.ssh_keys.0
  }

  source_image_reference {
    publisher = "kinvolk"
    offer     = "flatcar-container-linux"
    sku       = "stable"
    version   = var.flatcar_stable_version
  }

  plan {
    name      = "stable"
    product   = "flatcar-container-linux"
    publisher = "kinvolk"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

data "ct_config" "machine-ignitions" {
  for_each = toset(var.machines)
  content  = data.template_file.machine-configs[each.key].rendered
}

data "template_file" "machine-configs" {
  for_each = toset(var.machines)
  template = file("${path.module}/cl/machine-${each.key}.yaml.tmpl")

  vars = {
    ssh_keys = jsonencode(var.ssh_keys)
    name     = each.key
  }
}
