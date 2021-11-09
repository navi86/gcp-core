# list of jenkins plugins to be installed
variable "jenkins_plugins" {
  default = [
    "blueocean:1.24.8",
    "ansible:1.1",
    "job-dsl:1.77",
    "gcp-secrets-manager-credentials-provider:0.2.6"
  ]
}

variable "project" {
  description = "project where jenkins will be created object"
  #type = map
}

variable "gke_endpoint" {
  description = "gke endpoint"
  type        = string
}

variable "gke_cert" {
  description = "project infra object"
  type        = string
}

variable "tf_state_bucket" {
  type        = string
  description = "Terraform state bucket"
}

