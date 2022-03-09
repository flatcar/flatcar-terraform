output "ip-addresses" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => aws_instance.machine[key].public_ip
  }
}
