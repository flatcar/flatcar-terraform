terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
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

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "volumetmp" {
  name = "${var.cluster_name}-pool"
  type = "dir"
  path = "/var/tmp/${var.cluster_name}-pool"
}

resource "libvirt_volume" "base" {
  name   = "flatcar-base"
  source = var.base_image
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

resource "libvirt_volume" "vm-disk" {
  for_each       = toset(var.machines)
  # does not depend on the Ignition config and will be kept on user-data changes
  name           = "${var.cluster_name}-${each.key}.qcow2"
  base_volume_id = libvirt_volume.base.id
  pool           = libvirt_pool.volumetmp.name
  format         = "qcow2"
}

resource "libvirt_ignition" "ignition" {
  for_each = toset(var.machines)
  name     = "${var.cluster_name}-${each.key}-ignition"
  pool     = libvirt_pool.volumetmp.name
  content  = data.ct_config.vm-ignitions[each.key].rendered
}

resource "null_resource" "reboot-when-ignition-changes" {
  for_each = toset(var.machines)
  triggers = {
    ignition_config = libvirt_ignition.ignition[each.key].id
  }
  # hack: For QEMU we have to use "systemctl poweroff… virsh start" instead of just "systemctl reboot" because the QEMU process does not pick up the new Ignition config otherwise
  provisioner "local-exec" {
    command = "test -f .${each.key}.init && initial_run=no || initial_run=yes; touch .${each.key}.init; if [ $initial_run = yes ]; then exit 0; fi; while ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 core@${libvirt_domain.machine[each.key].network_interface.0.addresses.0} sudo touch /boot/flatcar/first_boot ; do sleep 1; done; while ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 core@${libvirt_domain.machine[each.key].network_interface.0.addresses.0} sudo systemctl poweroff; do sleep 1; done && while virsh --connect=qemu:///system shutdown ${var.cluster_name}-${each.key}; do sleep 1; done; virsh --connect=qemu:///system start ${var.cluster_name}-${each.key}"
  }
}

resource "libvirt_domain" "machine" {
  # hack: even though we ignore the changes here to keep the VM instance, the changes will still be applied when QEMU is restarted because the file contents are changed
  lifecycle {
    ignore_changes = [coreos_ignition]
  }
  for_each = toset(var.machines)
  name     = "${var.cluster_name}-${each.key}"
  vcpu     = var.virtual_cpus
  memory   = var.virtual_memory

  fw_cfg_name     = "opt/org.flatcar-linux/config"
  coreos_ignition = libvirt_ignition.ignition[each.key].id

  disk {
    volume_id = libvirt_volume.vm-disk[each.key].id
  }

  graphics {
    listen_type = "address"
  }

  # dynamic IP assignment on the bridge, NAT for Internet access
  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }
}

data "ct_config" "vm-ignitions" {
  for_each = toset(var.machines)
  content  = data.template_file.vm-configs[each.key].rendered
}

data "template_file" "vm-configs" {
  for_each = toset(var.machines)
  template = file("${path.module}/cl/machine-${each.key}.yaml.tmpl")

  vars = {
    ssh_keys = jsonencode(var.ssh_keys)
    name     = each.key
  }
}
