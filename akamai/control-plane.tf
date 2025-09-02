resource "linode_instance_config" "default-control-plane" {
  booted    = true
  linode_id = linode_instance.control-plane.id
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
    disk_id     = linode_instance_disk.flatcar-disk-control-plane.id
  }
}

resource "linode_instance_disk" "flatcar-disk-control-plane" {
  size      = linode_instance.control-plane.specs.0.disk
  linode_id = linode_instance.control-plane.id
  image     = linode_image.flatcar.id
  label     = "flatcar-boot"
}

resource "linode_instance" "control-plane" {
  label  = "control-plane-${random_string.suffix.result}"
  region = var.region
  type   = var.control_plane_type

  tags = ["flatcar", "control-plane"]

  metadata { user_data = base64encode(data.ct_config.control-plane.rendered) }
}

data "ct_config" "control-plane" {
  strict = true
  content = templatefile("${path.module}/server-configs/control-plane.yaml.tmpl", {
    kubernetes_version       = var.kubernetes_version
    kubernetes_minor_version = local.kubernetes_minor_version
  })
  snippets = [
    templatefile("${path.module}/server-configs/core-user.yaml.tmpl", {
      ssh_keys = jsonencode(var.ssh_keys),
    })
  ]
}
