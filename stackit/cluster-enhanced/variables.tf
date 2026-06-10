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

variable "maintenance_machine_image_updates" {
  type = bool
  description = "Enable automatic machine image updates in maintenance window"
  default = true
}

variable "maintenance_kubernetes_updates" {
  type = bool
  description = "Enable automatic kubernetes patch updates in maintenance window"
  default = true
}

variable "maintenance_window_start" {
  type = string
  description = "Start of maintenance window, the time of day in UTC (format: HH:MM:SSZ)"
  default = "01:00:00Z"
  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]Z$", var.maintenance_window_start))
    error_message = "The maintenance_window_end must be a valid UTC time in the format HH:MM:SSZ (e.g., 01:00:00Z). Max value is 23:59:59Z."
  }
}

variable "maintenance_window_end" {
  type = string
  description = "End of maintenance window, the time of day in UTC (format: HH:MM:SSZ)"
  default = "02:00:00Z"
  validation {
    condition = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]Z$", var.maintenance_window_end))
    error_message = "The maintenance_window_end must be a valid UTC time in the format HH:MM:SSZ (e.g., 01:00:00Z). Max value is 23:59:59Z."
  }
}

variable "observability_enabled" {
  type = bool
  description = "Enable observability extension"
  default = true
}

variable "observability_name" {
  type        = string
  description = "Observability name"
  default = "flatcar-observability"
}

variable "observability_plan" {
  type = string
  description = "Observability plan name"
  default = "Observability-Basic-EU01"
}
