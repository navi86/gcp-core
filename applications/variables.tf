#
locals {
  project_infra = data.terraform_remote_state.core.outputs.project_infra
  gke_endpoint  = data.terraform_remote_state.infra.outputs.gke.endpoint
  gke_cert      = data.terraform_remote_state.infra.outputs.gke.cert
  ansible_sa    = data.terraform_remote_state.infra.outputs.ansible_sa
}

/* variable "jenkins_plugins" {
  default = [
    "blueocean:1.24.8",
    "openshift-pipeline:1.0.57"
  ]
} */

variable "jenkins_plugins" {
  default = [
    /*     "kubernetes:1.29.2",
    "workflow-aggregator:2.6",
    "git:4.7.1",
    "configuration-as-code:1.47", */
    "blueocean:1.24.8"
  ]
}
