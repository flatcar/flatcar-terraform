output "ip-addresses" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => azurerm_linux_virtual_machine.machine[key].public_ip_address
  }
}
