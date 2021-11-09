variable "application_name" {
  type    = string
  default = "gcplab2"
}

variable "application_folder" {
  type    = string
  default = "app"
}

variable "infrastructure_folder" {
  type    = string
  default = "infra"
}

variable "service_levels" {
  type = map(string)
  default = {
    "snd" : "Sandbox",
    "dev" : "Development",
  }
}

variable "billing_account_id" {
  type    = string
  default = "01E57A-701C87-EBF8FA"
}

variable "region" {
  type    = string
  default = "us-central1"
}