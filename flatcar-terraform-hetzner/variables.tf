variable "machines" {
  type        = list(string)
  description = "Machine names, corresponding to machine-NAME.yaml.tmpl files"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name used as prefix for the machine names"
}

variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "Additional SSH public keys for user 'core'."
}

variable "server_type" {
  type        = string
  default     = "cx11"
  description = "The server type to rent."
}

variable "location" {
  type        = string
  default     = "fsn1"
  description = "The Hetzner region code for the region to deploy to."
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
