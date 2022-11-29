output "provisioning_public_key_file" {
  value = local_file.provisioning_key_pub.filename
}

output "provisioning_private_key_file" {
  value = local_file.provisioning_key.filename
}

output "ipv4" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => hcloud_server.machine[key].ipv4_address
  }
}

output "ipv6" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => hcloud_server.machine[key].ipv6_address
  }
}

output "id" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => hcloud_server.machine[key].id
  }
}

output "name" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => hcloud_server.machine[key].name
  }
}
