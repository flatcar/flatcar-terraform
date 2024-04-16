resource "brightbox_server_group" "kubernetes" {
  name = "Kubernetes server group"
}

resource "brightbox_firewall_policy" "kubernetes" {
  name         = "Kubernetes firewall policy"
  server_group = brightbox_server_group.kubernetes.id
}

resource "brightbox_firewall_rule" "kubernetes_api" {
  destination_port = 6443
  protocol         = "tcp"
  source           = "any"
  description      = "Kubernetes API access from anywhere"
  firewall_policy  = brightbox_firewall_policy.kubernetes.id
}

resource "brightbox_firewall_rule" "ssh" {
  destination_port = 22
  protocol         = "tcp"
  source           = "any"
  description      = "SSH access from anywhere"
  firewall_policy  = brightbox_firewall_policy.kubernetes.id
}

resource "brightbox_firewall_rule" "workers" {
  protocol        = "tcp"
  source          = data.brightbox_server_group.default.id
  firewall_policy = brightbox_firewall_policy.kubernetes.id
}

resource "brightbox_firewall_rule" "internet" {
  protocol        = "tcp"
  destination     = "any"
  firewall_policy = brightbox_firewall_policy.kubernetes.id
}

data "brightbox_server_group" "default" {
  name = "^default$"
}
