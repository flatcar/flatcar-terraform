terraform {
  required_providers {
    stackit = {
      source = "stackitcloud/stackit"
      version = "0.71.0"
    }
  }
}

provider "stackit" {
  default_region           = var.default_region
  service_account_key_path = var.service_account_key_path
  private_key_path         = var.private_key_path
}

resource "stackit_observability_instance" "flatcar_cluster_observability" {
  name       = var.observability_name
  plan_name  = var.observability_plan
  project_id = var.project_id
}

resource "stackit_ske_cluster" "flatcar_cluster" {
  project_id = var.project_id
  name = var.cluster_name
  node_pools = [
    {
      name = var.node_pool_name
      availability_zones = var.availability_zones
      machine_type = var.machine_type
      minimum = var.node_pool_minimum
      maximum = var.node_pool_maximum
    }
  ]

  maintenance = {
    enable_kubernetes_version_updates    = var.maintenance_kubernetes_updates
    enable_machine_image_version_updates = var.maintenance_machine_image_updates
    start                                = var.maintenance_window_start
    end                                  = var.maintenance_window_end
  }

  extensions = {
    observability = {
      enabled = var.observability_enabled
      instance_id = stackit_observability_instance.flatcar_cluster_observability.instance_id
    }
  }

  depends_on = [
    stackit_observability_instance.flatcar_cluster_observability
  ]
}

resource "time_sleep" "wait_for_kubeconfig" {
  depends_on = [stackit_ske_cluster.flatcar_cluster]

  create_duration = "30s"
}

# Sometimes, terraform tries to create a Kubeconfig, but the cluster is not yet found
resource "stackit_ske_kubeconfig" "flatcar_kubeconfig" {
  depends_on = [time_sleep.wait_for_kubeconfig]
  cluster_name = var.cluster_name
  project_id   = var.project_id

  refresh = true
  expiration = 7200 # 2 hours
  refresh_before = 3600 # 1 hour
}

resource "local_file" "kubeconfig" {
  content  = stackit_ske_kubeconfig.flatcar_kubeconfig.kube_config
  filename = "${path.module}/kubeconfig.yaml"

  directory_permission = "0700"
  file_permission      = "0600"
}

output "kubeconfig_export_command" {
  description = "Run this command to configure kubectl"
  value       = "export KUBECONFIG=${abspath(local_file.kubeconfig.filename)}"
}
