variable "cluster_name" {
  type        = string
  default     = "flatcar-cluster"
  description = "Name of the EKS cluster"
}

variable "aws_region" {
  type        = string
  default     = "us-east-2"
  description = "AWS Region to use for running the cluster"
}

variable "cluster_version" {
  type        = string
  default     = "1.18"
  description = "Version of Kubernetes that runs in the cluster"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for the worker nodes"
}

variable "bastion_instance_type" {
  type        = string
  default     = "t3.small"
  description = "Instance type for the bastion machine"
}

variable "worker_group_size" {
  type        = number
  default     = 2
  description = "Amount of workers in the worker group"
}

variable "flatcar_channel" {
  type        = string
  default     = "stable"
  description = "Flatcar channel to deploy on instances"
}

variable "ssh_public_key" {
  type        = string
  default     = ""
  description = "SSH Key to inject into bastion and workers to allow for remote connections."
}
