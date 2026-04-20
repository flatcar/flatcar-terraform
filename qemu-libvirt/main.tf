terraform {
  required_version = ">= 1.4"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "= 0.9.2"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "flatcar-simple"
}

variable "mac" {
  description = "MAC address for the VM"
  type        = string
  default     = "52:54:00:45:00:01"
}

variable "memory_mib" {
  description = "Memory size (MiB) for the VM"
  type        = number
  default     = 2048
}

variable "vcpu" {
  description = "vCPU count for the VM"
  type        = number
  default     = 2
}

variable "disk_capacity_bytes" {
  description = "System disk capacity in bytes (default 20 GiB)"
  type        = number
  default     = 21474836480
}

variable "channel" {
  description = "Flatcar Channel for the VM"
  type        = string
  default     = "stable"
}

variable "release" {
  description = "Flatcar Release for the VM"
  type        = string
  default     = "4459.2.3"
}

data "ct_config" "flatcar_simple" {
  content = <<-YAML
    variant: flatcar
    version: 1.1.0
    passwd:
      users:
        - name: core
          ssh_authorized_keys:
            - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFakeKeyForDocExampleOnly
  YAML
  strict  = false
}

resource "libvirt_ignition" "flatcar_simple" {
  name    = "${var.vm_name}.ign"
  content = data.ct_config.flatcar_simple.rendered
}

resource "libvirt_volume" "flatcar_base" {
  name = "flatcar-base-${var.channel}-${var.release}"
  pool = "default"
  # Flatcar base image — treat as immutable. Reuse across many VMs; never written to directly.

  create = {
    content = {
      url = "https://${var.channel}.release.flatcar-linux.net/amd64-usr/${var.release}/flatcar_production_qemu_image.img"
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "terraform_data" "system_volume" {
  # tracks every value that should cause the system disk to be recreated from scratch.
  # terraform_data is replaced (not just updated) when triggers_replace changes,
  # which cascades to libvirt_volume.flatcar_simple_system via replace_triggered_by below.
  triggers_replace = {
    vm_name  = var.vm_name
    capacity = var.disk_capacity_bytes
    ignition = libvirt_ignition.flatcar_simple.id  # ignition content changed
    base     = libvirt_volume.flatcar_base.id       # base image replaced
  }
}

resource "libvirt_volume" "flatcar_simple_system" {
  name     = "${var.vm_name}-system.qcow2"
  pool     = "default"
  capacity = var.disk_capacity_bytes

  # writable system disk is a qcow2 overlay backed by flatcar_base — copy-on-write,
  # so the base image is never modified regardless of what the VM writes.
  backing_store = {
    path = libvirt_volume.flatcar_base.path
    format = {
      type = "qcow2"
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }

  lifecycle {
    # the libvirt provider rejects in-place updates on volumes entirely.
    # ignore_changes = all prevents Terraform from ever planning a Modify;
    # all replacement decisions are driven by terraform_data.system_volume above.
    ignore_changes       = all
    replace_triggered_by = [terraform_data.system_volume]
  }
}

resource "libvirt_domain" "flatcar_simple" {
  name        = var.vm_name
  memory      = var.memory_mib
  memory_unit = "MiB"
  vcpu        = var.vcpu
  type        = "kvm"
  autostart   = false

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "q35"
  }

  features = {
    # acpi = true is REQUIRED when delivering Ignition via fw_cfg on a q35/OVMF machine.
    # Without it QEMU rejects the fw_cfg entry and Ignition never runs.
    acpi = true
  }

  sys_info = [
    {
      fw_cfg = {
        entry = [
          {
            name  = "opt/org.flatcar-linux/config"
            # fw_cfg passes the Ignition blob directly to the guest firmware — no disk or network required.
            file  = libvirt_ignition.flatcar_simple.path
            value = ""
          }
        ]
      }
    }
  ]

  devices = {
    disks = [
      {
        driver = {
          name = "qemu"
          type = "qcow2"
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        source = {
          volume = {
            pool   = libvirt_volume.flatcar_simple_system.pool
            volume = libvirt_volume.flatcar_simple_system.name
          }
        }
      }
    ]

    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "default"
          }
        }
        # single virtio NIC on the default libvirt bridge; adjust to your network if needed.
        mac = {
          address = var.mac
        }
      }
    ]

    consoles = [
      {
        type        = "pty"
        target_type = "virtio"
      }
    ]

    graphics = null
  }

  lifecycle {
    # domain must be recreated whenever the system disk is replaced,
    # otherwise libvirt keeps the old domain definition pointing at the new disk.
    replace_triggered_by = [
      libvirt_volume.flatcar_simple_system.id
    ]
  }
}
