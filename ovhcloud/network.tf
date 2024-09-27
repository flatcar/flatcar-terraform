resource "openstack_networking_secgroup_v2" "ssh" {
  name        = "ssh-terraform"
  description = "Allow SSH from the outside - Managed by Terraform"
  count       = var.ssh ? 1 : 0
}

resource "openstack_networking_secgroup_rule_v2" "ssh-ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ssh[0].id
  count             = var.ssh ? 1 : 0
}

resource "openstack_networking_secgroup_rule_v2" "ssh-ipv6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.ssh[0].id
  count             = var.ssh ? 1 : 0
}
