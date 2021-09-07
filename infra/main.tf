/* resource "google_container_registry" "registry" {
  project  = local.project_infra.project_id
  location = "EU"
} */

# docker push eu.gcr.io/gcplab-infra/jenkins:lts 

/* resource "google_project_service" "cloudrun" {
  project = local.project_infra.project_id
  service = "run.googleapis.com"
} */

# resource "google_cloud_run_service" "jenkins" {
#   name     = "jenkins"
#   location = "europe-north1"
#   project  = data.terraform_remote_state.core.outputs.project_infra_id

#   template {
#     spec {
#       containers {
#         image = "eu.gcr.io/gcplab-infra/jenkins:lts"
#       }
#     }
#   }

#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
# }

resource "google_service_account" "ansible" {
  account_id   = "ansible"
  display_name = "Ansible"
  description  = "sa for getting information about running compute instances in env"
  project      = local.project_infra.project_id
}

resource "google_project_iam_binding" "compute_viewer" {
  project = local.project_infra.project_id
  role    = "roles/compute.viewer"

  members = [
    "serviceAccount:${google_service_account.ansible.email}",
  ]
}
