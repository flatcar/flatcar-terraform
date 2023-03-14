output "ip-addresses" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => equinix_metal_device.machine[key].access_public_ipv4
  }
}
