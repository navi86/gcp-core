locals {
  project_infra   = data.terraform_remote_state.core.outputs.project_infra
  tf_state_bucket = data.terraform_remote_state.core.outputs.tf_state_bucket
  timestamp       = formatdate("YYMMDDhhmmss", timestamp())
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "application_name" {
  type = string
  default = "gcplab2"
}
