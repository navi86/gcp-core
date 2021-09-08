resource "google_compute_network" "shared" {
  project = local.project_infra.project_id
  name    = "${local.project_infra.project_id}-vpc-1"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "us_central1_subnet" {
  name                     = "${local.project_infra.project_id}-central1-subnet-1"
  project                  = local.project_infra.project_id
  ip_cidr_range            = cidrsubnet(lookup(var.region_subnets, "us-central1"), var.newbits, var.netnum)
  region                   = var.region
  network                  = google_compute_network.shared.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "main-central1-1-pods"
    ip_cidr_range = cidrsubnet(lookup(var.region_subnets, "us-central1-secondary_pod"), var.pods_newbits, var.pods_netnum) # 32768 per subnet
  }
  secondary_ip_range {
    range_name    = "main-central1-1-services"
    ip_cidr_range = cidrsubnet(lookup(var.region_subnets, "us-central1-secondary_svc"), var.svc_newbits - 1, var.svc_netnum) # 2046 per subnet
  }
}

resource "google_compute_firewall" "gke_allow_google_health_chk" {
  name    = "${google_compute_network.shared.name}-allow-google-health-chk"
  project = local.project_infra.project_id
  network = google_compute_network.shared.id

  allow {
    protocol = "all"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]
}

resource "google_compute_firewall" "gke_master_validator" {
  name    = "${google_compute_network.shared.name}-gke-master-validator"
  project = local.project_infra.project_id
  network = google_compute_network.shared.id

  allow {
    protocol = "tcp"
    ports    = ["80", "8443", "443", "8080", "8089"]
  }

  source_ranges = ["10.0.0.0/28", "10.0.0.16/28"]
}

resource "google_compute_firewall" "allow_ssh_icmp" {
  name    = "${google_compute_network.shared.name}-internet-internal-ssh-icmp-allow-rule"
  project = local.project_infra.project_id
  network = google_compute_network.shared.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${google_compute_network.shared.name}-internal-allow-rule"
  project = local.project_infra.project_id
  network = google_compute_network.shared.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.128.0.0/9"]
}

# create nat for accessing internet from vpc
module "nat_cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.1.0"

  name    = "${google_compute_network.shared.name}-router"
  project = local.project_infra.project_id
  network = google_compute_network.shared.name
  region  = var.region

  nats = [{
    name = "cnat-${google_compute_network.shared.name}"
  }]
}
