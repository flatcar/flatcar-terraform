
resource "proxmox_virtual_environment_vm" "instance" {
  for_each = toset(var.machines)
  clone {
    vm_id     = proxmox_virtual_environment_vm.flatcar_template.vm_id
    node_name = local.hypervisor
  }

  name      = each.key
  node_name = local.hypervisor
  started   = true

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  cdrom {
    enabled = true
    file_id = "${var.datastore_local}:iso/${each.key}_cloud_drive.iso"
  }

  lifecycle {
    ignore_changes = [
      node_name
    ]
  }
}

