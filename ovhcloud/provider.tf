terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
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

# Configure the OpenStack Provider
# See: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
# See: https://help.ovhcloud.com/csm/en-public-cloud-compute-terraform?id=kb_article_view&sysparm_article=KB0050797
provider "openstack" {
  user_name   = var.user_name
  tenant_name = var.tenant_name
  password    = var.password
  auth_url    = var.auth_url
  region      = var.region
}
