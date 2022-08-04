resource "kubernetes_config_map" "controller" {
  metadata {
    name      = var.cmc_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.cmc_name
      "app.kubernetes.io/component" = var.cmc_label_component
    }
  }

  data = {
    "apply_config.sh" = "${file("${path.module}/config.sh")}"
    "plugins.txt"     = "${file("${path.module}/plugins.txt")}"
  }
}
