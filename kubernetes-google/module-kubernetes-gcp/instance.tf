data "google_compute_zones" "available" { region = var.region }

data "google_compute_image" "flatcar" {
  family  = "flatcar-${var.channel}"
  project = "kinvolk-public"
}

resource "random_shuffle" "zones" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

resource "random_pet" "instance" {}

resource "google_compute_instance" "flatcar-instance" {
  count = var.cluster_size

  name         = "${random_pet.instance.id}-${count.index}"
  machine_type = var.machine_type
  zone         = random_shuffle.zones.result[0]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.flatcar.self_link
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }

  metadata = {
    env       = var.env
    user-data = count.index == 0 ? data.ct_config.controller[count.index].rendered : data.ct_config.worker[count.index].rendered
  }
}
