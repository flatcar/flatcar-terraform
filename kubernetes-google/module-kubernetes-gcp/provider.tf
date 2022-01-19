terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.6.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.9.1"
    }
  }
}

provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.region
  credentials = var.credentials
}
