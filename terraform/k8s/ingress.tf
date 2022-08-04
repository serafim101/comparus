resource "kubernetes_ingress_v1" "jenkins-ingress" {
  metadata {
    name      = var.ingress_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
  }

  spec {
    rule {
      host = var.ingress_domain
      http {
        path {
          path      = var.ingress_path
          path_type = var.inrgress_path_type
          backend {
            service {
              name = kubernetes_service.controller.metadata[0].name
              port {
                number = kubernetes_service.controller.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }
}
