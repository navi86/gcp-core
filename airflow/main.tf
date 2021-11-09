locals {
  project_id = "${var.application_name}-${var.service_level}"
}


# create gc projects of infrastructure
resource "google_composer_environment" "test" {
  name   = "${var.application_name}-${var.service_level}"
  project = local.project_id
  region = var.region
}
