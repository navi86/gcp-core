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

provider "helm" {
  kubernetes {
    #host                   = local.gke_endpoint
    #cluster_ca_certificate = local.gke_cert
    host                   = var.gke_endpoint
    cluster_ca_certificate = var.gke_cert
    token                  = data.google_client_config.default.access_token
  }
}

provider "kubernetes" {
  #host = local.gke_endpoint
  #cluster_ca_certificate = local.gke_cert
  host                   = var.gke_endpoint
  cluster_ca_certificate = var.gke_cert
  token                  = data.google_client_config.default.access_token
}
