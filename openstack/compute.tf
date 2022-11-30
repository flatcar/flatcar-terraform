# we let 'Nova' generate a new keypair.
resource "openstack_compute_keypair_v2" "provisioning_keypair" {
  name = "Provisioning key for Flatcar cluster ${var.cluster_name}"
}

# keypair is saved locally for later SSH connections.
resource "local_file" "provisioning_key" {
  filename             = "${path.module}/.ssh/provisioning_private_key.pem"
  content              = openstack_compute_keypair_v2.provisioning_keypair.private_key
  directory_permission = "0700"
  file_permission      = "0400"
}

resource "local_file" "provisioning_key_pub" {
  filename             = "${path.module}/.ssh/provisioning_key.pub"
  content              = openstack_compute_keypair_v2.provisioning_keypair.public_key
  directory_permission = "0700"
  file_permission      = "0440"
}

# Get the flavor ID
data "openstack_compute_flavor_v2" "flatcar" {
  name = var.flavor_name
}

# We create the OpenStack image by importing directly from the release servers.
resource "openstack_images_image_v2" "flatcar" {
  name             = "${var.cluster_name}-${var.release_channel}"
  image_source_url = "https://${var.release_channel}.release.flatcar-linux.net/amd64-usr/${var.flatcar_version}/flatcar_production_openstack_image.img.gz"
  container_format = "bare"
  disk_format      = "qcow2"
  web_download     = true
}

# 'instance' are the OpenStack instances created from the 'flatcar' image
# using user data.
resource "openstack_compute_instance_v2" "instance" {
  for_each  = toset(var.machines)
  name      = "${var.cluster_name}-${each.key}"
  image_id  = openstack_images_image_v2.flatcar.id
  flavor_id = data.openstack_compute_flavor_v2.flatcar.id
  key_pair  = openstack_compute_keypair_v2.provisioning_keypair.name

  network {
    name = "public"
  }

  user_data = data.ct_config.machine-ignitions[each.key].rendered
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
    ssh_keys = jsonencode(concat(var.ssh_keys, [openstack_compute_keypair_v2.provisioning_keypair.public_key]))
  }
}
