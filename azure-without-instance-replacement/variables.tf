variable "resource_group_location" {
  type        = string
  description = "Location of the resource group."
  default     = "eastus"
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
  description = "The server type to rent"
  default     = "Standard_D2s_v4"
}

variable "flatcar_alpha_version" {
  type        = string
  description = "The Flatcar Alpha release you want to use for the initial installation, must be >= 3535.0.0"
}

variable "ssh_port" {
  type        = string
  description = "Custom SSH port"
  default     = "22"
}

variable "mode" {
  type        = string
  description = "Reprovision mode (ssh or az)"
  default     = "ssh"
}
