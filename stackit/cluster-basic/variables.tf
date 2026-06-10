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

variable "cluster_name" {
  type        = string
  description = "Cluster name, max. 11 characters"
  default = "flatcar"
}

variable "machine_type" {
  type        = string
  default     = "c2i.4"
  description = "Machine type for the nodes"
}

variable "availability_zones" {
  type = list(string)
  default = ["eu01-2"]
  description = "Example node pool availability zones"
}

variable "node_pool_name" {
  type = string
  default = "pool-1"
  description = "Example node pool"
}

variable "node_pool_minimum" {
  type = number
  default = "1"
  description = "Example node pool minimum size"
}

variable "node_pool_maximum" {
  type = number
  default = "3"
  description = "Example node pool maximum size"
}
