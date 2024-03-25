output "ipv4" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => scaleway_instance_server.instance[key].public_ip
  }
}

output "ipv6" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => scaleway_instance_server.instance[key].ipv6_address
  }
}

output "name" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => scaleway_instance_server.instance[key].name
  }
}
