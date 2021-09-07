#
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.79.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.3"
    }
  }
  required_version = "~> 1.0.0"
}

data "google_client_config" "default" {}


data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

data "terraform_remote_state" "core" {
  backend = "local"

  config = {
    path = "../core/terraform.tfstate"
  }
}

provider "helm" {
  kubernetes {
    host                   = local.gke_endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = local.gke_cert
  }
}

provider "kubernetes" {
  host = local.gke_endpoint

  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = local.gke_cert
}