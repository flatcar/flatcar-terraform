data "template_file" "worker-config" {
  count = var.cluster_size

  template = file("${path.module}/files/worker.yml")

  vars = {
    env                = var.env
    index              = count.index
    ssh_pub_key        = var.ssh_pub_key
    kubernetes_version = var.kubernetes_version
  }
}

data "template_file" "controller-config" {
  count = var.cluster_size

  template = file("${path.module}/files/controller.yml")

  vars = {
    env                = var.env
    index              = count.index
    ssh_pub_key        = var.ssh_pub_key
    kubernetes_version = var.kubernetes_version
  }
}

data "ct_config" "worker" {
  count = var.cluster_size

  content      = data.template_file.worker-config[count.index].rendered
  pretty_print = true
}

data "ct_config" "controller" {
  count = var.cluster_size

  content      = data.template_file.controller-config[count.index].rendered
  pretty_print = true
}

