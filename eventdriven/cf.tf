data "archive_file" "source" {
  type        = "zip"
  source_dir  = "./src"
  output_path = "/tmp/function-${local.timestamp}.zip"
}

# Create bucket that will host the source code
resource "google_storage_bucket" "cf" {
  name    = "${var.application_name}-function"
  project = local.project_infra.project_id
}

# Add source code zip to bucket
resource "google_storage_bucket_object" "cf_zip" {
  # Append file MD5 to force bucket to be recreated
  name   = "source.zip#${data.archive_file.source.output_md5}"
  bucket = google_storage_bucket.cf.name
  source = data.archive_file.source.output_path
}

resource "google_cloudfunctions_function" "calculate_files" {
  name        = "calculate_files"
  description = "List files in bucket"
  runtime     = "python39"
  project     = local.project_infra.project_id
  region      = var.region

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.cf.name
  source_archive_object = google_storage_bucket_object.cf_zip.name
  #trigger_http          = false
  entry_point = "hello_pubsub"

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.file_update.name
    failure_policy {
      retry = true
    }
  }

}
