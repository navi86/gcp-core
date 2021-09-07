# creare gc folders
# resource "google_folder" "infrastructure" {
#   display_name = "${var.application_name}-${var.infrastructure_folder}"
#   parent       = "organizations/0"
# }

# resource "google_folder" "application" {
#   display_name = "${var.application_name}-${var.application_folder}"
#   parent       = "organizations/0"
# }


# create gc projects
resource "google_project" "infra" {
  name       = "${var.application_name} infra project"
  project_id = "${lower(var.application_name)}-infra"
  #folder_id  = google_folder.infrastructure.folder_id
  labels = {
    application = lower(var.application_name)
  }

 billing_account = var.billing_account_id
}

resource "google_project_service" "infra_compute" {
  project = "${lower(var.application_name)}-infra"
  service = "compute.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}

resource "google_project_service" "infra_container" {
  project = "${lower(var.application_name)}-infra"
  service = "container.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}




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
