resource "kubernetes_stateful_set" "controller" {
  metadata {
    name      = var.sts_name_controller
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  spec {
    service_name = kubernetes_service.controller.metadata[0].name
    replicas     = var.sts_replicas_controller
    selector {
      match_labels = {
        "app.kubernetes.io/name"      = var.label_name
        "app.kubernetes.io/component" = var.label_component
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = var.label_name
          "app.kubernetes.io/component" = var.label_component
        }
      }
      spec {
        security_context {
          run_as_user     = var.sts_sc_rau_controller
          fs_group        = var.sts_sc_fg_controller
          run_as_non_root = var.sts_sc_ranr_controller
        }
        service_account_name = kubernetes_service_account.jenkins_sa.metadata[0].name
        init_container {
          name              = var.sts_init_container_name
          image             = var.sts_image_controller
          image_pull_policy = var.sts_ic_ipp_controller
          security_context {
            allow_privilege_escalation = var.sts_ic_sc_ape_controller
            read_only_root_filesystem  = var.sts_ic_sc_rorf_controller
            run_as_user                = var.sts_sc_rau_controller
            run_as_group               = var.sts_sc_fg_controller
          }
          command = var.sts_ic_command_controller
          resources {
            requests = {
              cpu    = var.sts_ic_rr_cpu_controller
              memory = var.sts_ic_rr_ram_controller
            }
            limits = {
              cpu    = var.sts_ic_rl_cpu_controller
              memory = var.sts_ic_rl_ram_controller
            }
          }
          dynamic "volume_mount" {
            for_each = var.sts_ic_vm_controller
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.m_path
            }
          }
        }
        container {
          name              = var.sts_con_name_controller
          image             = var.sts_image_controller
          image_pull_policy = var.sts_con_ipp_controller
          security_context {
            allow_privilege_escalation = var.sts_ic_sc_ape_controller
            read_only_root_filesystem  = var.sts_ic_sc_rorf_controller
            run_as_user                = var.sts_sc_rau_controller
            run_as_group               = var.sts_sc_fg_controller
          }
          args = var.sts_con_args_controller
          dynamic "env" {
            for_each = var.sts_con_env_controller
            content {
              name  = env.value["name"]
              value = env.value["value"]
            }
          }
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          dynamic "port" {
            for_each = var.sts_con_ports_controller
            content {
              name           = port.value["name"]
              container_port = port.value["port"]
            }
          }
          startup_probe {
            failure_threshold = var.sts_con_sp_failureThreshold
            http_get {
              path = var.sts_con_sp_path
              port = var.sts_con_sp_portname
            }
            period_seconds  = var.sts_con_sp_periodSeconds
            timeout_seconds = var.sts_con_sp_timeoutSeconds
          }
          liveness_probe {
            failure_threshold = var.sts_con_lp_failureThreshold
            http_get {
              path = var.sts_con_lp_path
              port = var.sts_con_lp_portname
            }
            period_seconds  = var.sts_con_lp_periodSeconds
            timeout_seconds = var.sts_con_lp_timeoutSeconds
          }
          readiness_probe {
            failure_threshold = var.sts_con_rp_failureThreshold
            http_get {
              path = var.sts_con_rp_path
              port = var.sts_con_rp_portname
            }
            period_seconds  = var.sts_con_rp_periodSeconds
            timeout_seconds = var.sts_con_rp_timeoutSeconds
          }
          resources {
            requests = {
              cpu    = var.sts_con_rr_cpu_controller
              memory = var.sts_con_rr_ram_controller
            }
            limits = {
              cpu    = var.sts_con_rl_cpu_controller
              memory = var.sts_con_rl_ram_controller
            }
          }
          dynamic "volume_mount" {
            for_each = var.sts_con_vm_controller
            content {
              name       = volume_mount.value["name"]
              mount_path = volume_mount.value["mount_path"]
            }
          }
        }
        container {
          name              = var.sts_con_name_cr
          image             = var.sts_con_image_cr
          image_pull_policy = var.sts_con_ipp_cr
          security_context {
            allow_privilege_escalation = var.sts_ic_sc_ape_controller
            read_only_root_filesystem  = var.sts_ic_sc_rorf_controller
          }
          dynamic "env" {
            for_each = var.sts_con_env_cr
            content {
              name  = env.value["name"]
              value = env.value["value"]
            }
          }
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          dynamic "volume_mount" {
            for_each = var.sts_con_vm_cr
            content {
              name       = volume_mount.value["name"]
              mount_path = volume_mount.value["mount_path"]
            }
          }
        }
        dynamic "volume" {
          for_each = var.sts_vols
          content {
            name = volume.value["name"]
            empty_dir {
              medium = ""
            }
          }
        }
        volume {
          name = "jenkins-config"
          config_map {
            name = kubernetes_config_map.controller.metadata[0].name
          }
        }
        volume {
          name = "jenkins-secrets"
          projected {
            sources {
              secret {
                name = kubernetes_secret.creds.metadata[0].name
                items {
                  key  = "jenkins-admin-user"
                  path = "admin-username"
                }
                items {
                  key  = "jenkins-admin-password"
                  path = "admin-password"
                }
              }
            }
          }
        }
        volume {
          name = "jenkins-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pvc.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubernetes_persistent_volume.pv]
}
