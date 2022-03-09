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
  description = "SSH public keys for user 'core'"
}

variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "AWS Region to use for running the machine"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for the machine"
}

variable "vpc_cidr" {
  type    = string
  default = "172.16.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "172.16.10.0/24"
}
