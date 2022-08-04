resource "kubernetes_service" "controller" {
  metadata {
    name      = var.svc_controller
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  spec {
    type = var.svc_type_controller
    port {
      name        = var.svc_port_name_controller
      port        = var.svc_port_controller
      target_port = var.svc_target_port_controller
      node_port   = var.svc_nodeport_controller
    }
    selector = {
      "app.kubernetes.io/component" = var.label_component
    }
  }
}
