terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.79.0"
    }
  }
  required_version = "~> 1.0.0"
}

terraform {
  backend "gcs" {
    bucket = "gcplab2-tf"
    prefix = "eventdriven"
  }
}


data "google_client_config" "default" {}

data "terraform_remote_state" "core" {
  backend = "gcs"
  config = {
    bucket = "gcplab2-tf"
    prefix = "core"
  }
}
