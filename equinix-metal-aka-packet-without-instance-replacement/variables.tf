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
  description = "SSH public keys for user 'core', only needed if you don't have it specified in the Equinix Metal Project"
}

variable "facilities" {
  type        = list(string)
  default     = ["sjc1"]
  description = "List of facility codes with deployment preferences"
}

variable "plan" {
  type        = string
  default     = "t1.small.x86"
  description = "The device plan slug"
}

variable "project_id" {
  type        = string
  description = "The Equinix Metal Project to deploy in (in the web UI URL after /projects/)"
}
