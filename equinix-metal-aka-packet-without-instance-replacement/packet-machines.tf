terraform {
  required_version = ">= 0.13"
  required_providers {
    packet = {
      source  = "packethost/packet"
      version = "3.1.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.7.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.19.0"
    }
  }
}

resource "null_resource" "reboot-when-ignition-changes" {
  for_each = toset(var.machines)
  triggers = {
    ignition_config = data.ct_config.machine-ignitions[each.key].rendered
  }
  # Wait for the new Ignition config object to be ready before rebooting
  depends_on = [aws_s3_bucket_object.object]
  # Trigger running Ignition on the next reboot and reboot the instance
  provisioner "local-exec" {
    command = "test -f .${each.key}.init && initial_run=no || initial_run=yes; touch .${each.key}.init; if [ $initial_run = yes ]; then exit 0; fi; while ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 core@${packet_device.machine[each.key].access_public_ipv4} sudo touch /boot/flatcar/first_boot ; do sleep 1; done; while ! ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o NumberOfPasswordPrompts=0 core@${packet_device.machine[each.key].access_public_ipv4} sudo systemctl reboot; do sleep 1; done"
  }
}

resource "packet_device" "machine" {
  for_each         = toset(var.machines)
  hostname         = "${var.cluster_name}-${each.key}"
  plan             = var.plan
  facilities       = var.facilities
  operating_system = "flatcar_stable"
  billing_cycle    = "hourly"
  project_id       = var.project_id
  # Workaround: Indirection through AWS S3 because "lifecycle { ignore_changes = [user_data] }" will not update the user data and leaving it out would replace the instance
  user_data        = "{ \"ignition\": { \"version\": \"2.1.0\", \"config\": { \"replace\": { \"source\": \"s3://${aws_s3_bucket_object.object[each.key].bucket}/${aws_s3_bucket_object.object[each.key].id}\" } } } }"
}

resource "aws_s3_bucket" "user-data-forcenew-workaround" {
  bucket = "user-data-forcenew-workaround-${var.cluster_name}"
  acl    = "public-read"
}

# Ignition config, publicly accessible
resource "aws_s3_bucket_object" "object" {
  bucket   = aws_s3_bucket.user-data-forcenew-workaround.id
  for_each = toset(var.machines)
  key      = "${var.cluster_name}-${each.key}"
  acl      = "public-read"
  content  = data.ct_config.machine-ignitions[each.key].rendered
}

data "ct_config" "machine-ignitions" {
  for_each = toset(var.machines)
  content  = data.template_file.machine-configs[each.key].rendered
}

data "template_file" "machine-configs" {
  for_each = toset(var.machines)
  template = file("${path.module}/cl/machine-${each.key}.yaml.tmpl")

  vars = {
    ssh_keys = jsonencode(var.ssh_keys)
    name     = each.key
  }
}

