# https://cloud.google.com/solutions/best-practices-vpc-design
/* resource "google_compute_network" "vpc_custom" {
  project = local.project_infra.project_id
  name    = "ec-main-${local.project_infra.project_id}-vpc-0"

  auto_create_subnetworks = false
} */

/* module "nat_cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.1.0"

  name    = "router-${lookup(var.gke_network_main, "vpc_name")}"
  project = local.project.project_id
  network = lookup(var.gke_network_main, "vpc_name")
  region  = local.region

  nats = [{
    name = "cnat-${lookup(var.gke_network_main, "vpc_name")}"
  }]
} */

/* module "nat_cloud_router_us_cent1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.1.0"

  name    = "router-${lookup(var.gke_network_main, "vpc_name")}"
  project = local.project.project_id
  network = lookup(var.gke_network_main, "vpc_name")
  region  = local.us-cent-region

  nats = [{
    name = "cnat-${lookup(var.gke_network_main, "vpc_name")}"
  }]
} */

# Peering
/* resource "google_compute_network_peering" "ec-dev-to-ec-source" {
  name         = "ec-dev-to-ec-source"
  network      = data.google_compute_network.default.id
  peer_network = "projects/elementalcognition-app-source/global/networks/ec-main-src-vpc-0"
} */

resource "google_compute_network" "vpc_custom" {
  project = local.project_infra.project_id
  name    = "${local.project_infra.project_id}-vpc-0"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "us_central1_subnet" {
  name                     = "main-${local.project_infra.project_id}-central1-subnet"
  project                  = local.project_infra.project_id
  ip_cidr_range            = cidrsubnet(lookup(var.region_subnets, "us-central1"), var.newbits, var.netnum)
  region                   = "us-central1"
  network                  = google_compute_network.vpc_custom.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "main-central1-0-pods"
    ip_cidr_range = cidrsubnet(lookup(var.region_subnets, "us-central1-secondary_pod"), var.pods_newbits, var.pods_netnum) # 32768 per subnet
  }
  secondary_ip_range {
    range_name    = "main-central1-0-services"
    ip_cidr_range = cidrsubnet(lookup(var.region_subnets, "us-central1-secondary_svc"), var.svc_newbits - 1, var.svc_netnum) # 2046 per subnet
  }
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "main-peering-${local.project_infra.project_id}"
  project       = local.project_infra.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_custom.id
}

/* resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_custom.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
} */


resource "google_compute_firewall" "allow-google-health-chk" {
  name    = "allow-google-health-chk"
  project = local.project_infra.project_id
  network = google_compute_network.vpc_custom.id

  allow {
    protocol = "all"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]
}

/* resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_custom.id

  allow {
    protocol = "all"
  }

  source_ranges = [
    google_compute_subnetwork.us_central1_subnet.ip_cidr_range,
    cidrsubnet(lookup(var.region_subnets, "us-east4-secondary_pod"), var.pods_newbits, var.pods_netnum),
  ]
} */

resource "google_compute_firewall" "gke-master-validator" {
  name    = "gke-master-validator"
  project = local.project_infra.project_id
  network = google_compute_network.vpc_custom.id

  allow {
    protocol = "tcp"
    ports    = ["80", "8443", "443", "8080", "8089"]
  }

  source_ranges = ["10.0.0.0/28", "10.0.0.16/28"]
}

