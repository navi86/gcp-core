# create gc projects of infrastructure
resource "google_project" "infra" {
  name       = "${var.application_name} infra project"
  project_id = "${lower(var.application_name)}-infra"
  #folder_id  = google_folder.infrastructure.folder_id
  labels = {
    application = lower(var.application_name)
  }

 billing_account = var.billing_account_id
}

# enable google api for project
resource "google_project_service" "infra_compute" {
  project = google_project.infra.project_id
  service = "compute.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}

resource "google_project_service" "infra_container" {
  project = google_project.infra.project_id
  service = "container.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}

resource "google_project_service" "infra_secretmanager" {
  project = google_project.infra.project_id
  service = "secretmanager.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}

# create project for each environment
resource "google_project" "service_levels" {
  for_each   = var.service_levels
  name       = "${var.application_name} ${each.value} project"
  project_id = "${lower(var.application_name)}-${lower(each.key)}"
#  folder_id  = google_folder.application.folder_id
  labels = {
    application = lower(var.application_name)
    environment = lower(each.key)
  }

 billing_account = var.billing_account_id
}

# create gcs bucket for storing terraform state. this gcs bucket also contains state of this module(core)
resource "google_storage_bucket" "tf_state" {

  project  = google_project.infra.project_id
  name     = "${lower(var.application_name)}-tf"
  location = var.region
  #force_destroy = true

  versioning {
    enabled = true
  }
}
