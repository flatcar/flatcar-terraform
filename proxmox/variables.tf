variable "machines" {
  type        = list(string)
  description = "Machine names, corresponding to templates/machine-NAME.yaml"
}

variable "datastore_local" {
  default     = "local"
  description = "datastore_id of hypervisor local storage"
  type        = string
}

variable "datastore_vm" {
  default     = "local-zfs"
  description = "datastore_id of VM storage"
  type        = string
}

variable "flatcar_version" {
  type        = string
  description = "The Flatcar version associated to the release channel"
  default     = "current"
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

variable "ssh_keys" {
  default     = []
  description = "List of ssh-keys to authenticate to the flatcar VM"
  type        = list(string)
}

variable "vm_name" {
  default     = "test-flatcar"
  description = "proxmox VM name (also used as hostname in this repository)"
  type        = string
}
