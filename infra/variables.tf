locals {
  project_infra = data.terraform_remote_state.core.outputs.project_infra
  tf_state_bucket = data.terraform_remote_state.core.outputs.tf_state_bucket
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "region_subnets" {
  type = map(any)
  default = {
    us-central1               = "10.15.0.0/16"
    us-central1-secondary_pod = "10.248.0.0/14"
    us-central1-secondary_svc = "10.252.0.0/16"
  }
}

variable "newbits" {
  type    = number
  default = 4
}

variable "netnum" {
  type    = number
  default = 1
}

# GKE pods addresses
variable "pods_newbits" {
  type    = number
  default = 4
}

variable "pods_netnum" {
  type    = number
  default = 1
}

# GEK services addresses
variable "svc_newbits" {
  type    = number
  default = 6
}

variable "svc_netnum" {
  type    = number
  default = 1
}
