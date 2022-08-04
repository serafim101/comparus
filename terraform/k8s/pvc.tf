resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = var.pvc_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  spec {
    access_modes = var.pvc_accessModes
    resources {
      requests = {
        storage = var.pvc_storage_size
      }
    }
    storage_class_name = kubernetes_persistent_volume.pv.metadata[0].name
  }
}
