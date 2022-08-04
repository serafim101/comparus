resource "kubernetes_persistent_volume" "pv" {
  metadata {
    name = var.pv_name
  }

  spec {
    storage_class_name = var.pv_name
    access_modes       = var.pv_access_mode
    capacity = {
      storage = var.pv_size
    }
    persistent_volume_reclaim_policy = var.pv_reclaim_policy
    persistent_volume_source {
      host_path {
        path = var.pv_path
      }
    }
  }
}
