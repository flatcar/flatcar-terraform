variable "ssh_keys" {
  type        = list(string)
  default     = []
  description = "Additional SSH public keys for user 'core'."
}

variable "api_version" {
  type        = string
  default     = "v4beta"
  description = "Linode API version"
}

variable "token" {
  type        = string
  description = "Linode API token"
}

variable "region" {
  type        = string
  description = "Linode region"
  default     = "us-ord"
}

variable "control_plane_type" {
  type        = string
  description = "Linode control plane instance type"
  default     = "g6-standard-2"
}

variable "worker_type" {
  type        = string
  description = "Linode worker instance type"
  default     = "g6-nanode-1"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "v1.32.1"
}

variable "workers" {
  type        = number
  description = "Number of workers"
  default     = "3"
}

locals {
  kubernetes_minor_version = regex("^(v\\d+\\.\\d+)", var.kubernetes_version)[0]

}
