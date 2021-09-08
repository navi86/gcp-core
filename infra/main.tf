# create ansible key file and store it in the project for possibility ansible connect to all instances in the project
resource "tls_private_key" "ansible_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_secret_manager_secret" "ansible_ssh" {
  secret_id = "ansible_ssh"
  project = local.project_infra.project_id

  labels = {
    jenkins-credentials-type = "ssh-user-private-key"
    jenkins-credentials-username= "ansible"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "ansible_ssh" {

  secret      = google_secret_manager_secret.ansible_ssh.id
  secret_data = tls_private_key.ansible_ssh.private_key_pem
}

resource "google_compute_project_metadata" "linux_ssh" {
  project = local.project_infra.project_id
  metadata = {
    ssh-keys = <<EOF
      ansible:${chomp(tls_private_key.ansible_ssh.public_key_openssh)} ansible
    EOF
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to metadata, because google add keys for accessing gke nodes 
      # so terraform would every run try to delete extra keys 
      metadata
    ]
  }
}

# install jenkins
module "jenkins" {
  source = "../jenkins"
  
  project = local.project_infra
  gke_endpoint  = "https://${module.gke.endpoint}"
  gke_cert      = base64decode(module.gke.ca_certificate)
  tf_state_bucket      = local.tf_state_bucket
  
}
