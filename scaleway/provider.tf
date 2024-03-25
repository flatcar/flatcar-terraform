terraform {
  required_version = ">= 0.14.0"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.38.2"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.11.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

# Configure the ScaleWay Provider
provider "scaleway" {
  access_key      = var.access_key
  secret_key      = var.secret_key
  project_id      = var.project_id
  organization_id = var.organization_id
  region          = var.region
  zone            = var.zone
}

