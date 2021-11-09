# create ansible key file and store it in the project for possibility ansible connect to all instances in the project
/* resource "google_service_account" "pubsub" {
  account_id   = "pubsub-sa"
  display_name = "Pub/Sub Service Account"
  project = local.project_infra.project_id
} */

resource "google_storage_bucket" "files" {

  project  = local.project_infra.project_id
  name     = "${lower(var.application_name)}-files"
  location = var.region
  #force_destroy = true

  versioning {
    enabled = true
  }
}

resource "google_pubsub_topic" "file_update" {
  name    = "eventdriven"
  project = local.project_infra.project_id
}

resource "google_pubsub_subscription" "retention" {
  name  = "files-retention"
  topic = google_pubsub_topic.file_update.name
  project = local.project_infra.project_id
  message_retention_duration = "604800s"
}

resource "google_pubsub_topic_iam_binding" "topic_eventdriven" {
  project = local.project_infra.project_id
  topic = google_pubsub_topic.file_update.name
  role = "roles/editor"
  members = [
    #"serviceAccount:${google_service_account.pubsub.email}",
    "serviceAccount:service-${local.project_infra.number}@gs-project-accounts.iam.gserviceaccount.com"
  ]
}

resource "google_storage_notification" "notification" {
  bucket              = google_storage_bucket.files.name
  payload_format      = "JSON_API_V1"
  topic               = google_pubsub_topic.file_update.id
  event_types         = ["OBJECT_FINALIZE", "OBJECT_METADATA_UPDATE"]
  depends_on = [google_pubsub_topic_iam_binding.topic_eventdriven]
}
