variable "project" { type = string }
variable "region" { type = string }
variable "credentials" { type = string }
variable "env" { type = string }

variable "kubernetes_version" { type = string }
variable "channel" { type = string }
variable "machine_type" { type = string }

variable "cluster_size" { type = string }

variable "ssh_pub_key" { type = string }
variable "cni" { type = string }
