variable "machines" {
  type        = list(string)
  description = "Machine names, corresponding to cl/machine-NAME.yaml.tmpl files"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name used as prefix for the machine names"
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH public keys for user 'core' and to register on Hetzner Cloud"
}

variable "server_type" {
  type        = string
  default     = "cx11"
  description = "The server type to rent"
}

variable "datacenter" {
  type        = string
  description = "The region to deploy in"
}
