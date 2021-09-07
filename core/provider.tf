terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.79.0"
    }
  }
  required_version = "~> 1.0.0"
}

# provider "google" {
#   project = local.project
# }
