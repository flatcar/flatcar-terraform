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

variable "api_client" {
  type        = string
  description = "Brightbox API client"
}

variable "api_secret" {
  type        = string
  description = "Brightbox API secret"
}

variable "zone" {
  type        = string
  description = "Brightbox zone"
  default     = "gb1-a"
}

variable "control_plane_type" {
  type        = string
  description = "Brightbox control plane instance type"
  default     = "4gb.ssd"
}

variable "worker_type" {
  type        = string
  description = "Brightbox worker instance type"
  default     = "1gb.ssd"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "v1.29.2"
}

variable "workers" {
  type        = number
  description = "Number of workers"
  default     = "3"
}
