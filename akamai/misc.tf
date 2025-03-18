resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
  numeric = false
}
