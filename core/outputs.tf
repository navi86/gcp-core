output "project_infra" {
  value = google_project.infra
}

output "tf_state_bucket" {
  value = google_storage_bucket.tf_state.name
}
