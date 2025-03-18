resource "linode_image" "flatcar" {
  label       = "flatcar"
  description = "Flatcar upload"
  region      = var.region
  tags        = ["flatcar"]

  file_path = "./flatcar_production_akamai_image.bin.gz"
  file_hash = filemd5("./flatcar_production_akamai_image.bin.gz")

  # required for Ignition
  cloud_init = true
}
