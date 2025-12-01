terraform {
  required_providers {
    stackit = {
      source = "stackitcloud/stackit"
      version = "0.71.0"
    }
  }
}

provider "stackit" {
  default_region           = var.default_region
  service_account_key_path = var.service_account_key_path
  private_key_path         = var.private_key_path
  enable_beta_resources = true
}

resource "stackit_network" "flatcar_network" {
  name       = var.network_name
  project_id = var.project_id

  ipv4_nameservers = [
    "1.1.1.1",
    "8.8.8.8"
  ]
}

resource "stackit_security_group" "flatcar_security_group" {
  name       = var.security_group_name
  project_id = var.project_id
}

resource "stackit_security_group_rule" "flatcar_security_group_rule" {
  project_id = var.project_id
  direction  = "ingress"
  security_group_id = stackit_security_group.flatcar_security_group.security_group_id
  protocol = {
    name = "tcp"
  }
  port_range = {
    min = 22
    max = 22
  }
}

resource "stackit_key_pair" "flatcar_key_pair" {
  name       = var.key_pair_name
  public_key = chomp(file(var.public_key))
}

resource "stackit_image" "flatcar_image" {
  project_id = var.project_id
  name = var.image_name
  disk_format     = "qcow2"
  local_file_path = var.image_path
}

resource "stackit_network_interface" "flatcar_network_interface" {
  network_id = stackit_network.flatcar_network.network_id
  project_id = var.project_id
  security_group_ids = [
    stackit_security_group.flatcar_security_group.security_group_id
  ]
  depends_on = [
    stackit_network.flatcar_network
  ]
}

resource "stackit_public_ip" "flatcar_public_ip" {
  project_id = var.project_id
  network_interface_id = stackit_network_interface.flatcar_network_interface.network_interface_id
  depends_on = [
    stackit_network.flatcar_network,
    stackit_network_interface.flatcar_network_interface
  ]
}

resource "stackit_server" "flatcar_server" {
  machine_type = var.machine_type
  name         = var.server_name
  project_id   = var.project_id

  boot_volume = {
    size        = 50
    source_type = "image"
    source_id   = stackit_image.flatcar_image.image_id
    delete_on_termination = var.delete_disk_on_termination
  }
  availability_zone = var.availability_zone
  keypair_name = stackit_key_pair.flatcar_key_pair.name
  network_interfaces = [
    stackit_network_interface.flatcar_network_interface.network_interface_id
  ]

  depends_on = [
    stackit_network.flatcar_network,
    stackit_security_group.flatcar_security_group,
    stackit_security_group_rule.flatcar_security_group_rule,
    stackit_public_ip.flatcar_public_ip,
    stackit_key_pair.flatcar_key_pair,
    stackit_network_interface.flatcar_network_interface
  ]
}

output "ssh_instruction" {
  value = "Use ssh core@${stackit_public_ip.flatcar_public_ip.ip} -i ${trimsuffix(var.public_key, ".pub")} to connect to the server"
}
