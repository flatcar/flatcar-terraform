variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

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
  description = "SSH public keys for user 'core' (and to register directly with waagent for the first)"
}

variable "server_type" {
  type        = string
  default     = "Standard_D2s_v4"
  description = "The server type to rent"
}

variable "flatcar_stable_version" {
  type        = string
  description = "The Flatcar Stable release you want to use for the initial installation, e.g., 2605.12.0"
}
