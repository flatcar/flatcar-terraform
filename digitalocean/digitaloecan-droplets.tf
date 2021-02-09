terraform {
  required_version = ">= 0.13"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.5.1"
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

resource "digitalocean_ssh_key" "first" {
  name       = var.cluster_name
  public_key = var.ssh_keys.0
}

resource "digitalocean_custom_image" "flatcar" {
  name   = "flatcar-stable-${var.flatcar_stable_version}"
  url    = "https://stable.release.flatcar-linux.net/amd64-usr/${var.flatcar_stable_version}/flatcar_production_digitalocean_image.bin.bz2"
  regions = [var.datacenter]
}

resource "digitalocean_droplet" "machine" {
  for_each  = toset(var.machines)
  name      = "${var.cluster_name}-${each.key}"
  image     = digitalocean_custom_image.flatcar.id
  region    = var.datacenter
  size      = var.server_type
  ssh_keys  = [digitalocean_ssh_key.first.fingerprint]
  user_data = data.ct_config.machine-ignitions[each.key].rendered
}

data "ct_config" "machine-ignitions" {
  for_each = toset(var.machines)
  content  = data.template_file.machine-configs[each.key].rendered
}

data "template_file" "machine-configs" {
  for_each = toset(var.machines)
  template = file("${path.module}/machine-${each.key}.yaml.tmpl")

  vars = {
    ssh_keys = jsonencode(var.ssh_keys)
    name     = each.key
  }
}
