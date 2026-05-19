locals {
  cluster_name = lower("${var.cluster_name}-${var.cluster_type}")
}

locals {
  kubeconfig_path = try(
    module.cluster_kind[0].kubeconfig_path,
    #module.cluster_eks[0].kubeconfig_path
  )
  
}

module "cluster_kind" {
  source = "./modules/cluster-kind"
  count  = var.cluster_type == "kind" ? 1 : 0
  name = local.cluster_name
}

module "github_repository" {
  source                   = "./modules/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux0"
}

module "tls_private_key" {
  source = "./modules/tf-hashicorp-tls-keys"
  }

module "flux_bootstrap" {
  source            = "./modules/fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.cluster_kind[0].kubeconfig_path
}
