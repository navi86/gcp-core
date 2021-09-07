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

output "ansible_sa" {
  value = google_service_account.ansible
}