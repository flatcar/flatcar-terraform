data "brightbox_image" "flatcar" {
  name        = "^flatcar-${var.release_channel}.*server$"
  arch        = "x86_64"
  official    = true
  most_recent = true
}

resource "brightbox_server" "control-plane" {
  image         = data.brightbox_image.flatcar.id
  name          = "control-plane"
  zone          = var.zone
  type          = var.control_plane_type
  user_data     = data.ct_config.config-control-plane.rendered
  server_groups = [brightbox_server_group.kubernetes.id]
  depends_on    = [brightbox_firewall_policy.kubernetes]
}

resource "brightbox_server" "worker" {
  count     = var.workers
  image     = data.brightbox_image.flatcar.id
  name      = "worker-${count.index}"
  zone      = var.zone
  type      = var.worker_type
  user_data = data.ct_config.config-worker.rendered
}

data "ct_config" "config-control-plane" {
  strict = true
  content = templatefile("${path.module}/server-configs/control-plane.yaml.tmpl", {
    kubernetes_version = var.kubernetes_version
  })
  snippets = [
    data.template_file.core_user.rendered
  ]
}

data "ct_config" "config-worker" {
  strict = true
  content = templatefile("${path.module}/server-configs/worker.yaml.tmpl", {
    kubernetes_version = var.kubernetes_version
    control_plane_ip   = brightbox_cloudip.control-plane.public_ipv4
  })
}

data "template_file" "core_user" {
  template = file("${path.module}/core-user.yaml.tmpl")
  vars = {
    ssh_keys = jsonencode(var.ssh_keys)
  }
}

resource "brightbox_cloudip" "control-plane" {
  target = brightbox_server.control-plane.interface
  name   = "control-plane public address"
}
