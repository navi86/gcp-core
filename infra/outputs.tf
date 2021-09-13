output "subnetwork_infra" {
  value = google_compute_subnetwork.us_central1_subnet
}

output "gke" {
  sensitive = true
  value = {
    "endpoint" = "https://${module.gke.endpoint}"
    "token"    = data.google_client_config.default.access_token
    "cert"     = base64decode(module.gke.ca_certificate)
    "name"     = module.gke.name
    "region"   = var.region
  }
  description = "GKE cluster parameters"
}
