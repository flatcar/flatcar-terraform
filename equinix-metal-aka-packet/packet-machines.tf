terraform {
  required_version = ">= 0.13"
  required_providers {
    packet = {
      source  = "packethost/packet"
      version = "3.1.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.7.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

resource "packet_device" "machine" {
  for_each         = toset(var.machines)
  hostname         = "${var.cluster_name}-${each.key}"
  plan             = var.plan
  facilities       = var.facilities
  operating_system = "flatcar_stable"
  billing_cycle    = "hourly"
  project_id       = var.project_id
  user_data        = data.ct_config.machine-ignitions[each.key].rendered
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

