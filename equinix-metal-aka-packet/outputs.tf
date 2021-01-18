output "ip-addresses" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => packet_device.machine[key].access_public_ipv4
  }
}
