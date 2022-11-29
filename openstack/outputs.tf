output "provisioning_public_key_file" {
  value = local_file.provisioning_key_pub.filename
}

output "provisioning_private_key_file" {
  value = local_file.provisioning_key.filename
}

output "ipv4" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => openstack_compute_instance_v2.instance[key].access_ip_v4
  }
}

output "ipv6" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => openstack_compute_instance_v2.instance[key].access_ip_v6
  }
}

output "name" {
  value = {
    for key in var.machines :
    "${var.cluster_name}-${key}" => openstack_compute_instance_v2.instance[key].name
  }
}
