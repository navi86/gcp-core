locals {
  project_infra = data.terraform_remote_state.core.outputs.project_infra
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "gke_network_main" {
  type = object({
    vpc_name = string
    us-central1 = object({
      primary_name      = string
      ip_range_pods     = string
      ip_range_services = string
    })
    }
  )
  default = {
    vpc_name = "ec-main-dev-vpc-0"
    us-central1 = {
      primary_name      = "ec-main-na-cent1-dev-subnet"
      ip_range_pods     = "ec-main-na-cent1-0-pods"
      ip_range_services = "ec-main-na-cent1-0-services"
    }
  }
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
