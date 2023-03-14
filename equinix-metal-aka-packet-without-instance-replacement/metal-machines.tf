terraform {
  required_version = ">= 0.13"
  required_providers {
    metal = {
      source  = "equinix/equinix"
      version = "1.13.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.11.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
    equinix = {
      source = "terraform-providers/equinix"
    }
  }
}

resource "null_resource" "reboot-when-ignition-changes" {
  for_each = toset(var.machines)
  triggers = {
    ignition_config    = data.ct_config.machine-ignitions[each.key].rendered
    reprovision_helper = data.template_file.reprovision[each.key].rendered
  }
  # Wait for the new Ignition config object to be ready before rebooting
  depends_on = [equinix_metal_device.machine]
  # Trigger running Ignition on the next reboot and reboot the instance
  provisioner "local-exec" {
    command = data.template_file.reprovision[each.key].rendered
  }
}

data "template_file" "reprovision" {
  for_each = toset(var.machines)
  template = file("${path.module}/reprovision-helper")

  vars = {
    # Space separated list of regexes for data to keep when reconfiguring the instance with Ignition (quote with ' only, using " is not allowed)
    KEEPPATHS = "'/etc/ssh/ssh_host_.*' /mydata /var/log"
    PUBLICIP  = equinix_metal_device.machine[each.key].access_public_ipv4
    NAME      = equinix_metal_device.machine[each.key].hostname
  }
}

resource "equinix_metal_device" "machine" {
  for_each         = toset(var.machines)
  hostname         = "${var.cluster_name}-${each.key}"
  plan             = var.plan
  facilities       = var.facilities
  operating_system = "flatcar_alpha" # requires at least Alpha 3535.0.0
  billing_cycle    = "hourly"
  project_id       = var.project_id
  user_data        = data.ct_config.machine-ignitions[each.key].rendered

  behavior {
    allow_changes = [
      "user_data"
    ]
  }
}

data "ct_config" "machine-ignitions" {
  for_each = toset(var.machines)
  content  = data.template_file.machine-configs[each.key].rendered
  strict   = true
}

data "template_file" "machine-configs" {
  for_each = toset(var.machines)
  template = file("${path.module}/cl/machine-${each.key}.yaml.tmpl")

  vars = {
    ssh_keys = jsonencode(var.ssh_keys)
    name     = each.key
  }
}

