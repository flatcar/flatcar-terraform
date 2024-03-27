locals {
  cloud_drives = { for vm in var.machines :
    vm => "${path.module}/cloud_drives/${vm}/cloud_drive.iso"
  }
}

data "ct_config" "ignition" {
  for_each = toset(var.machines)
  content = templatefile("templates/machine-${each.key}.yaml", {
    ssh_keys = var.ssh_keys
  })

  strict = true
}
resource "local_file" "userdata_ignition" {
  for_each = toset(var.machines)
  content  = data.ct_config.ignition[each.key].rendered
  filename = "${path.module}/cloud_drives/${each.key}/drive/openstack/latest/user_data"
}

resource "local_file" "meta_data_openstack" {
  for_each = toset(var.machines)
  content = templatefile("${path.module}/templates/meta_data.json", {
    vm_name = each.key
  })
  filename = "${path.module}/cloud_drives/${each.key}/drive/openstack/latest/meta_data.json"
}

# Create cloud-drive cdrom locally
resource "null_resource" "cloud_init_drive" {
  for_each = toset(var.machines)
  provisioner "local-exec" {
    command = "mkisofs -output ${local.cloud_drives[each.key]} -volid config-2 -joliet -r ${path.module}/cloud_drives/${each.key}/drive"
  }

  depends_on = [local_file.meta_data_openstack, local_file.userdata_ignition]
}

# Upload cloud_drives to proxmox
resource "proxmox_virtual_environment_file" "cloud_drive" {
  for_each     = toset(var.machines)
  content_type = "iso"
  datastore_id = var.datastore_local
  node_name    = local.hypervisor

  source_file {
    file_name = "${each.key}_cloud_drive.iso"
    path      = local.cloud_drives[each.key]
  }
}
