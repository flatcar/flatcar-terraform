terraform {
  required_version = ">= 0.13"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.23.0"
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

resource "hcloud_ssh_key" "first" {
  name       = var.cluster_name
  public_key = var.ssh_keys.0
}

resource "hcloud_server" "machine" {
  for_each = toset(var.machines)
  name     = "${var.cluster_name}-${each.key}"
  ssh_keys = [hcloud_ssh_key.first.id]
  # boot into rescue OS
  rescue = "linux64"
  # dummy value for the OS because Flatcar is not available
  image       = "debian-9"
  server_type = var.server_type
  datacenter  = var.datacenter
  connection {
    host    = self.ipv4_address
    timeout = "1m"
  }
  provisioner "file" {
    content     = data.ct_config.machine-ignitions[each.key].rendered
    destination = "/root/ignition.json"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "curl -fsSLO --retry-delay 1 --retry 60 --retry-connrefused --retry-max-time 60 --connect-timeout 20 https://raw.githubusercontent.com/kinvolk/init/flatcar-master/bin/flatcar-install",
      "chmod +x flatcar-install",
      "./flatcar-install -s -i /root/ignition.json",
      "shutdown -r +1",
    ]
  }

  # optional:
  provisioner "remote-exec" {
    connection {
      host    = self.ipv4_address
      timeout = "3m"
      user    = "core"
    }

    inline = [
      "sudo hostnamectl set-hostname ${self.name}",
    ]
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

