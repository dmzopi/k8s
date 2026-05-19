variable "name" {
  type = string
}

locals {
  kubeconfig_path = pathexpand("${path.root}/kubeconfig/${var.name}-kubeconfig")
}

resource "kind_cluster" "this" {
  name           = var.name
  wait_for_ready = true
  kubeconfig_path = local.kubeconfig_path
}

resource "local_file" "kubeconfig" {
  filename = local.kubeconfig_path
  content  = kind_cluster.this.kubeconfig
}
