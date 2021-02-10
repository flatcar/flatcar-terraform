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
  description = "SSH public keys for user 'core' (and to register on Digital Ocean for the first)"
}

variable "server_type" {
  type        = string
  default     = "s-1vcpu-1gb"
  description = "The server type to rent"
}

variable "datacenter" {
  type        = string
  description = "The region to deploy in"
}

variable "flatcar_stable_version" {
  type        = string
  description = "The Flatcar Stable release you want to use for the initial installation, e.g., 2605.12.0"
}
