variable "application_name" {
  type    = string
  default = "gcplab"
}

variable "application_folder" {
  type    = string
  default = "app"
}

variable "infrastructure_folder" {
  type    = string
  default = "infra"
}

variable "service_level" {
  type    = string
  default = "snd"
}

/* variable "billing_account_id" {
  type = string
  default = "011AF5-A3572E-042E59"
} */

variable "region" {
  type    = string
  default = "us-central1"
}
