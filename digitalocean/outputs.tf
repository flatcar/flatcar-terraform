output "ip-addresses" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => digitalocean_droplet.machine[key].ipv4_address
  }
}
