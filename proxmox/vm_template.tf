data "proxmox_virtual_environment_nodes" "available_nodes" {}

locals {
  hypervisor = element(data.proxmox_virtual_environment_nodes.available_nodes.names, 0)
  image_file = "flatcat-openstack-${var.release_channel}-${var.flatcar_version}.img"
}

resource "proxmox_virtual_environment_download_file" "flatcar_image" {

  content_type = "iso"
  datastore_id = var.datastore_local
  node_name    = local.hypervisor
  file_name    = local.image_file
  overwrite    = false
  url          = "https://${var.release_channel}.release.flatcar-linux.net/amd64-usr/${var.flatcar_version}/flatcar_production_openstack_image.img.gz"

  decompression_algorithm = "gz"
}

resource "proxmox_virtual_environment_vm" "flatcar_template" {
  depends_on = [proxmox_virtual_environment_download_file.flatcar_image]

  name      = "flatcar-${var.release_channel}-${var.flatcar_version}"
  node_name = local.hypervisor

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
  }
  disk {
    datastore_id = var.datastore_vm
    file_id      = "${var.datastore_local}:iso/${local.image_file}"
    interface    = "virtio0"
  }

  template = true
}
