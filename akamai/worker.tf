resource "linode_instance_config" "default-worker" {
  count     = var.workers
  booted    = true
  linode_id = linode_instance.worker[count.index].id
  label     = "default"
  kernel    = "linode/direct-disk"
  helpers {
    devtmpfs_automount = false
    distro             = false
    modules_dep        = false
    network            = false
    updatedb_disabled  = true
  }
  device {
    device_name = "sda"
    disk_id     = linode_instance_disk.flatcar-disk-worker[count.index].id
  }
}

resource "linode_instance_disk" "flatcar-disk-worker" {
  count     = var.workers
  size      = linode_instance.worker[count.index].specs.0.disk
  linode_id = linode_instance.worker[count.index].id
  image     = linode_image.flatcar.id
  label     = "flatcar-boot"
}

resource "linode_instance" "worker" {
  count  = var.workers
  label  = "worker-${random_string.suffix.result}-${count.index}"
  region = var.region
  type   = var.worker_type

  tags = ["flatcar", "worker"]

  metadata { user_data = base64encode(data.ct_config.worker.rendered) }
}

data "ct_config" "worker" {
  strict = true
  content = templatefile("${path.module}/server-configs/worker.yaml.tmpl", {
    kubernetes_version       = var.kubernetes_version
    kubernetes_minor_version = local.kubernetes_minor_version
    control_plane_ip         = linode_instance.control-plane.ip_address
  })
}
