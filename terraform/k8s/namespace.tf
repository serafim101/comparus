resource "kubernetes_namespace" "jenkins_ns" {
  metadata {
    name = var.namespace_name
  }
}
