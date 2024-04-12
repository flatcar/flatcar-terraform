terraform {
  required_version = ">= 0.14.0"
  required_providers {
    brightbox = {
      source  = "brightbox/brightbox"
      version = "3.4.3"
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

provider "brightbox" {
  apiclient = var.api_client
  apisecret = var.api_secret
}

