variable "project_id" {
  type = string
  description = "STACKIT project id"
}

variable "service_account_key_path" {
  type = string
  description = "STACKIT service account key path"
}

variable "private_key_path" {
  type = string
  description = "STACKIT private key path"
}

variable "default_region" {
  type = string
  description = "Default region for STACKIT resources"
  default = "eu01"
}

variable "server_name" {
  type        = string
  description = "Server name"
  default = "flatcar"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the nodes"
  default     = "n2.14d.g1"
}

variable "availability_zone" {
  type = string
  description = "Server availability zones"
  default = "eu01-2"
}

variable "delete_disk_on_termination" {
  type = bool
  description = "Delete disk on server termination"
  default = true
}

variable "network_name" {
  type = string
  description = "Network for server"
  default = "flatcar_network"
}

variable "security_group_name" {
  type = string
  description = "Security group for server"
  default = "flatcar_security_group"
}

variable "key_pair_name" {
  type = string
  description = "Key pair name"
  default = "flatcar_ssh_key"
}

variable "public_key" {
  type = string
  description = "Local path to public key"
}

variable "image_name" {
  type = string
  description = "Machine image name"
  default = "Flatcar"
}

variable "image_path" {
  type = string
  description = "Local path to Flatcar image (OEM OpenStack or OEM STACKIT)"
}
