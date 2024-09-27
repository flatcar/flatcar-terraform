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

# We create the OVHcloud image
#
# XXX not supporting web_download + specify properties (notably
# for block-storage to avoid using virtio-blk instead of SCSI)
resource "openstack_images_image_v2" "flatcar" {
  name             = "${var.cluster_name}-${var.release_channel}.${var.flatcar_version}"
  image_source_url = "https://${var.release_channel}.release.flatcar-linux.net/amd64-usr/${var.flatcar_version}/flatcar_production_openstack_image.img.gz"
  # XXX do not use it, OVH openstack seems to not handle this well :(
  # web_download      = false
  verify_checksum  = true
  decompress       = true
  container_format = "bare"
  disk_format      = "qcow2"
  protected        = false
  hidden           = false
  visibility       = "private"

  # See: https://docs.openstack.org/glance/stein/admin/useful-image-properties.html
  # See: https://wiki.openstack.org/wiki/VirtDriverImageProperties
  properties = {
    architecture              = "x86_64"
    image_original_user       = "core"
    distro_family             = "gentoo"
    os_distro                 = "gentoo"
    os_version                = var.flatcar_version
    os_release_channel        = var.release_channel
    os_arch                   = "amd64"
    os_type                   = "linux"
    # XXX OVHcloud supports 256 volumes by VM, use SCSI to be able to use this
    # feature. If you do not specify this it will fallback to virtio-blk and
    # you'll only be able to use 26 volumes (including the root one).
    hw_disk_bus               = "scsi"
    hw_scsi_model             = "virtio-scsi"
    hypervisor_type           = "qemu"
    hw_qemu_guest_agent       = true
    hw_vif_model              = "virtio"
    hw_vif_multiqueue_enabled = true
    hw_time_hpet              = true
  }

  timeouts {
    create = "5m"
  }
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

  security_groups = flatten([["default"], var.ssh ? [openstack_networking_secgroup_v2.ssh[0].name] : []])
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
