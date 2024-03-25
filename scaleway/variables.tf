variable "machines" {
  type        = list(string)
  description = "Machine names, corresponding to machine-NAME.yaml.tmpl files"
  default     = ["server1"]
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

variable "flatcar_version" {
  type        = string
  description = "The Flatcar version associated to the release channel"
  default     = "current"
}

variable "region" {
  type        = string
  description = "Scaleway region"
  default     = "fr-par"
}

variable "organization_id" {
  type        = string
  description = "Scaleway organization ID"
}

variable "project_id" {
  type        = string
  description = "Scaleway project ID"
}

variable "access_key" {
  type        = string
  description = "Scaleway access key"
}

variable "secret_key" {
  type        = string
  description = "Scaleway secret key"
}

variable "zone" {
  type        = string
  description = "Scaleway zone"
  default     = "fr-par-1"
}

variable "type" {
  type        = string
  description = "Scaleway instance type"
  default     = "DEV1-S"
}

variable "flatcar_file" {
  type        = string
  description = "Path to the Flatcar file"
  default     = "./flatcar_production_scaleway_image.img"
}
