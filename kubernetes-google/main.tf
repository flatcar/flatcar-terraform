module "kubernetes" {
  source = "./module-kubernetes-gcp"

  project     = var.project
  region      = var.region
  credentials = var.credentials
  env         = var.env

  # Node configuration
  channel      = "alpha"
  machine_type = "e2-medium"
  ssh_pub_key  = file("~/.ssh/id_rsa.pub")

  # Cluster configuration
  cluster_size = 3

  # Kubernetes configuration
  kubernetes_version = "v1.23.0"
  cni                = "calico"
}
