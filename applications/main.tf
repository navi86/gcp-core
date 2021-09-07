#
resource "kubernetes_namespace" "infra" {
  provider = kubernetes

  metadata {
    name = "infra"
  }
}

resource "helm_release" "jenkins" {
  name      = "jenkins"
  namespace = kubernetes_namespace.infra.metadata.0.name

  repository = "https://charts.jenkins.io"
  chart      = "jenkins"

  set {
    name  = "controller.additionalPlugins"
    value = "{${join(",", var.jenkins_plugins)}}"
  }

  /*   set {
    name  = "controller.installPlugins"
    value = "{${join(",", var.jenkins_plugins)}}"
  } */

  /*   set {
      name = "adminUser"
      value = "admin"
  }

  set {
      name = "adminPassword"
      value = "adminPassword!1"
  } */

}

resource "kubernetes_service_account" "ansible" {
  metadata {
    name      = "ansible"
    namespace = kubernetes_namespace.infra.metadata.0.name
    annotations = {
      "iam.gke.io/gcp-service-account" = local.ansible_sa.email # required for workload identity
    }
  }

}
