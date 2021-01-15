output "ip-addresses" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => hcloud_server.machine[key].ipv4_address
  }
}
