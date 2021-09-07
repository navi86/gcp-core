/* provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
} */

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-nodes"
  project      = local.project_infra.project_id
  display_name = "GKE Nodes"
  description  = "GKE nodes dedicated service account"
}

module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  #version = "16.1.0"
  project_id         = local.project_infra.project_id
  name               = "gke-test-1"
  region             = var.region
  zones              = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network            = google_compute_network.vpc_custom.name
  subnetwork         = google_compute_subnetwork.us_central1_subnet.name
  kubernetes_version = "1.20.9-gke.2100"

  # Default ranges will be used if empty
  ip_range_pods     = google_compute_subnetwork.us_central1_subnet.secondary_ip_range.0.range_name
  ip_range_services = google_compute_subnetwork.us_central1_subnet.secondary_ip_range.1.range_name

  http_load_balancing        = true
  horizontal_pod_autoscaling = true
  network_policy             = false

  remove_default_node_pool = true

  #enable_private_endpoint    = true
  #enable_private_nodes       = true
  #master_ipv4_cidr_block     = "10.0.0.0/28"
  #istio = true
  #cloudrun = true
  #dns_cache = false

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "us-central1-b,us-central1-c"
      min_count                 = 1
      max_count                 = 5
      local_ssd_count           = 0
      local_ssd_ephemeral_count = 0
      disk_size_gb              = 50
      disk_type                 = "pd-standard"
      image_type                = "COS"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 2
      service_account           = google_service_account.gke_nodes.email
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    /*     default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ] */
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}