terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.79.0"
    }
  }
  required_version = "~> 1.0.0"
}

terraform {
  backend "gcs" {
    bucket  = "gcplab-tf"
    prefix  = "infra"
  }
}


data "google_client_config" "default" {}

data "terraform_remote_state" "core" {
  backend = "gcs" 
  config = {
    bucket  = "gcplab-tf"
    prefix  = "core"
  }
}
