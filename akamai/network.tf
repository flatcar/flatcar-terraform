resource "linode_firewall" "control-plane" {
  label = "control-plane"

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "8080"
    ipv4     = [for i in range(var.workers) : "${linode_instance.worker[i].ip_address}/32"]
  }

  inbound {
    label    = "allow-api-server"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "6443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [linode_instance.control-plane.id]
}

resource "linode_firewall" "worker" {
  label = "worker"

  inbound {
    label    = "allow-kubelet-api"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10250"
    ipv4     = ["${linode_instance.control-plane.ip_address}/32"]
  }

  inbound {
    label    = "allow-kube-proxy"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10256"
    ipv4     = ["${linode_instance.control-plane.ip_address}/32"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [for i in range(var.workers) : linode_instance.worker[i].id]
}
