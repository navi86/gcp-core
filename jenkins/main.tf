## creating jenkins sa for workload identity and give required permissions
resource "google_service_account" "jenkins" {
  account_id   = "jenkins"
  display_name = "Jenkins"
  description  = "sa for getting information about running compute instances"
  project      = var.project.project_id
}

resource "google_project_iam_binding" "compute_viewer" {
  project      = var.project.project_id
  role    = "roles/compute.viewer"

  members = [
    "serviceAccount:${google_service_account.jenkins.email}",
  ]
}

resource "google_project_iam_binding" "secretmanager_secretAccessor" {
  project      = var.project.project_id
  role    = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${google_service_account.jenkins.email}",
  ]
}

resource "google_project_iam_binding" "secretmanager_viewer" {
  project      = var.project.project_id
  role    = "roles/secretmanager.viewer"

  members = [
    "serviceAccount:${google_service_account.jenkins.email}",
  ]
}

resource "google_storage_bucket_iam_binding" "storage_objectAdmin" {
  bucket = var.tf_state_bucket
  role    = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.jenkins.email}",
  ]
}


resource "kubernetes_namespace" "jenkins" {
  provider = kubernetes

  metadata {
    name = "jenkins"
  }
}

# jenkins credentials
resource "google_secret_manager_secret" "github_access_token" {
  secret_id = "github_access_token"
  project      = var.project.project_id

  labels = {
    jenkins-credentials-type = "username-password"
    jenkins-credentials-username= "github_access_token"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github_access_token" {

  secret      = google_secret_manager_secret.github_access_token.id
  secret_data = "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"
}

# enable jenkins sa using workload identity in nameskape
resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata.0.name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.jenkins.email # required for workload identity
    }
  }
}

resource "google_service_account_iam_member" "workload_identity_iam" {
  service_account_id = google_service_account.jenkins.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project.project_id}.svc.id.goog[${kubernetes_namespace.jenkins.metadata.0.name}/${kubernetes_service_account.jenkins.metadata.0.name}]"
}


# generate jenkins password
resource "google_secret_manager_secret" "jenkins_password" {
  secret_id = "jenkins_password"
  project      = var.project.project_id

  labels = {
    label = "jenkins"
  }

  replication {
    automatic = true
  }
}

resource "random_password" "jenkins_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_secret_manager_secret_version" "jenkins_password" {

  secret      = google_secret_manager_secret.jenkins_password.id
  secret_data = random_password.jenkins_password.result
}


resource "helm_release" "jenkins" {
  name      = "jenkins"
  namespace = kubernetes_namespace.jenkins.metadata.0.name

  repository = "https://charts.jenkins.io"
  chart      = "jenkins"

  timeout = 30 # there is no benefit to wait more than 60 seconds because it's probably something wrong if timeout is exceeded

  set {
      name  = "controller.adminPassword"
      value = random_password.jenkins_password.result
    }
  
  set {
    name  = "controller.ingress.enabled"
    value = true
  }

# specify list of required plugins to be installed in jenkins
  set {
    name  = "controller.additionalPlugins"
    value = "{${join(",", var.jenkins_plugins)}}"
  }

# configure custom jenkins agent image due to the requirements to have gcloud and ansible
  set {
    name = "agent.image"
    value = "navi86/jenkins-inbound-agent"
  }

  set {
    name = "agent.tag"
    value = "1.0"
  }

# we are using gcp workcload identity so we we should create it in terraform and properly configure
set {
    name = "serviceAccount.create"
    value = false
  }
set {
    name = "serviceAccount.name"
    value = kubernetes_service_account.jenkins.metadata.0.name
  }

# specify SA for jenkins agent pod
set {
    name = "serviceAccountAgent.create"
    value = false
  }
set {
    name = "serviceAccountAgent.name"
    value = kubernetes_service_account.jenkins.metadata.0.name
  }

# Jenkins as code
values = [
    templatefile("${path.module}/files/JCasC.yml",
    {
      project  = var.project.project_id
    }
    )
  ]
}



