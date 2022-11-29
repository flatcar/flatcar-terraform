resource "tls_private_key" "provisioning" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "provisioning_key" {
  name       = "Provisioning key for Flatcar cluster '${var.cluster_name}'"
  public_key = tls_private_key.provisioning.public_key_openssh
}

resource "local_file" "provisioning_key" {
  filename             = "${path.module}/.ssh/provisioning_private_key.pem"
  content              = tls_private_key.provisioning.private_key_pem
  directory_permission = "0700"
  file_permission      = "0400"
}

resource "local_file" "provisioning_key_pub" {
  filename             = "${path.module}/.ssh/provisioning_key.pub"
  content              = tls_private_key.provisioning.public_key_openssh
  directory_permission = "0700"
  file_permission      = "0440"
}


resource "hcloud_server" "machine" {
  for_each = toset(var.machines)
  name     = "${var.cluster_name}-${each.key}"
  ssh_keys = [hcloud_ssh_key.provisioning_key.id]
  # boot into rescue OS
  rescue = "linux64"
  # dummy value for the OS because Flatcar is not available
  image       = "debian-11"
  server_type = var.server_type
  location    = var.location
  connection {
    host        = self.ipv4_address
    private_key = tls_private_key.provisioning.private_key_pem
    timeout     = "1m"
  }
  provisioner "file" {
    content     = data.ct_config.machine-ignitions[each.key].rendered
    destination = "/root/ignition.json"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "apt update",
      "apt install -y gawk",
      "curl -fsSLO --retry-delay 1 --retry 60 --retry-connrefused --retry-max-time 60 --connect-timeout 20 https://raw.githubusercontent.com/flatcar/init/flatcar-master/bin/flatcar-install",
      "chmod +x flatcar-install",
      "./flatcar-install -s -i /root/ignition.json -C ${var.release_channel}",
      "shutdown -r +1",
    ]
  }

  provisioner "remote-exec" {
    connection {
      host        = self.ipv4_address
      private_key = tls_private_key.provisioning.private_key_pem
      timeout     = "3m"
      user        = "core"
    }

    inline = [
      "sudo hostnamectl set-hostname ${self.name}",
    ]
  }
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
    ssh_keys = jsonencode(concat(var.ssh_keys, [tls_private_key.provisioning.public_key_openssh]))
  }
}
