resource "kubernetes_service" "agent" {
  metadata {
    name      = var.svc_name_agent
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  spec {
    type = var.svc_type_agent
    port {
      name        = var.svc_port_name_agent
      port        = var.svc_port_agent
      target_port = var.svc_target_port_agent
    }
    selector = {
      "app.kubernetes.io/component" = var.label_component
    }
  }
}
