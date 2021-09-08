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
    bucket  = "gcplab-tf"
    prefix  = "core"
  }
}