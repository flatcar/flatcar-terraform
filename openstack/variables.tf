variable "machines" {
  type        = list(string)
  description = "Machine names, corresponding to machine-NAME.yaml.tmpl files"
  default     = []
}

variable "cluster_name" {
  type        = string
  description = "Cluster name used as prefix for the machine names"
  default     = "terraform-flatcar"
}

variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "Additional SSH public keys for user 'core'."
}

variable "release_channel" {
  type        = string
  description = "Release channel"
  default     = "stable"

  validation {
    condition     = contains(["lts", "stable", "beta", "alpha"], var.release_channel)
    error_message = "release_channel must be lts, stable, beta, or alpha."
  }
}

variable "flavor_name" {
  type        = string
  description = "The OpenStack flavor to use (a.k.a the spec of the instance)"
  default     = "ds1G"
}

variable "flatcar_version" {
  type        = string
  description = "The Flatcar version associated to the release channel"
  default     = "current"
}

variable "user_name" {
  type        = string
  description = "OpenStack username"
}

variable "tenant_name" {
  type        = string
  description = "OpenStack tenant name"
}

variable "password" {
  type        = string
  description = "OpenStack password"
}

variable "auth_url" {
  type        = string
  description = "OpenStack authentication URL"
}

variable "region" {
  type        = string
  description = "OpenStack region"
  default     = "RegionOne"
}

variable "ssh" {
  type        = bool
  description = "Allow SSH connection from the outside"
  default     = false
}
