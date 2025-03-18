terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
  }
}

provider "linode" {
  token       = var.token
  api_version = var.api_version
}
