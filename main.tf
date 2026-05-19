terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.45"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.8"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################
# K8S (EKS)
############################

module "k8s" {
  source       = "./modules/k8s"
  cluster_name = var.cluster_name
}




# TLS KEY
module "tls_private_key" {
  source = "./modules/tls_private_key"
}


# GITHUB REPO PROVISION
module "github_repository" {
  source                   = "./modules/github_repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux0"
}

# FLUX PROVIDER

provider "flux" {
  kubernetes = {
    config_path = module.k8s.kubeconfig_path
  }

  git = {
    url = "ssh://git@github.com/${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}.git"

    ssh = {
      username    = "git"
      private_key = module.tls_private_key.private_key_pem
    }
  }
}

# FLUX BOOTSTRAP MODULE

module "fluxcd" {
  source       = "./modules/fluxcd"
  cluster_name = var.cluster_name
  depends_on = [
    module.k8s,
    module.github_repository,
    module.tls_private_key
  ]
}