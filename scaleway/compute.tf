resource "scaleway_object_bucket" "bucket" {
  name = "snapshot-flatcar-import"
}

resource "scaleway_object" "qcow" {
  bucket = scaleway_object_bucket.bucket.name
  key    = "flatcar_production_scaleway_image.qcow2"
  file   = var.flatcar_file
}

resource "scaleway_instance_snapshot" "snapshot" {
  type = "unified"
  import {
    bucket = scaleway_object.qcow.bucket
    key    = scaleway_object.qcow.key
  }
}

resource "scaleway_instance_volume" "from_snapshot" {
  from_snapshot_id = scaleway_instance_snapshot.snapshot.id
  type             = "b_ssd"
}

resource "scaleway_instance_server" "instance" {
  for_each = toset(var.machines)
  type     = var.type
  user_data = {
    "cloud-init" = data.ct_config.machine-ignitions[each.key].rendered
  }
  root_volume {
    volume_id = scaleway_instance_volume.from_snapshot.id
  }

  ip_id = scaleway_instance_ip.public_ip.id
}

data "ct_config" "machine-ignitions" {
  for_each = toset(var.machines)
  strict   = true
  content  = file("${path.module}/server-configs/${each.key}.yaml")
  snippets = [
    data.template_file.core_user.rendered
  ]
}

data "template_file" "core_user" {
  template = file("${path.module}/core-user.yaml.tmpl")
  vars = {
    ssh_keys = jsonencode(var.ssh_keys)
  }
}

resource "scaleway_instance_ip" "public_ip" {}
