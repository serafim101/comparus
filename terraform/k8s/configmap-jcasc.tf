resource "kubernetes_config_map" "jcasc" {
  metadata {
    name      = var.cmj_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.cmj_name
      "app.kubernetes.io/component" = var.cmc_label_component
      jenkins-config                = "true"
    }
  }

  data = {
    "jcasc-default-config.yaml" = "${file("${path.module}/jcasc-default-config.yaml")}"
  }
}
