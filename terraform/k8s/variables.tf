# Provider variables
variable "kubeconfig_path" {
  default = "~/.kube/config"
}

variable "config_context" {
  default = "minikube"
}


# Namespace variables
variable "namespace_name" {
  default = "jenkins"
}


# Labels variables
variable "label_name" {
  default = "jenkins"
}

variable "label_component" {
  default = "jenkins-controller"
}


# Service account & RBAC variables
variable "sa_name" {
  default = "jenkins"
}

variable "cr_name" {
  default = "jenkins"
}

variable "cr_api_groups" {
  default = ["*"]
}

variable "cr_resources" {
  default = [
    "statefulsets",
    "services",
    "replicationcontrollers",
    "replicasets",
    "podtemplates",
    "podsecuritypolicies",
    "pods",
    "pods/log",
    "pods/exec",
    "podpreset",
    "poddisruptionbudget",
    "persistentvolumes",
    "persistentvolumeclaims",
    "jobs",
    "endpoints",
    "deployments",
    "deployments/scale",
    "daemonsets",
    "cronjobs",
    "configmaps",
    "namespaces",
    "events",
    "secrets"
  ]
}

variable "cr_verbs" {
  default = [
    "create",
    "get",
    "watch",
    "delete",
    "list",
    "patch",
    "update"
  ]
}

variable "cr_api_groups_2" {
  default = [""]
}

variable "cr_resources_2" {
  default = [
    "nodes"
  ]
}

variable "cr_verbs_2" {
  default = [
    "get",
    "list",
    "watch",
    "update"
  ]
}

variable "rb_name" {
  default = "jenkins"
}

variable "kr_schedule_agent_name" {
  default = "jenkins-schedule-agents"
}

variable "kr_schedule_agent_rules" {
  default = [
    {
      api_grps = [""]
      res      = ["pods", "pods/exec", "pods/log", "persistentvolumeclaims", "events"]
      verb     = ["get", "list", "watch"]
    },
    {
      api_grps = [""]
      res      = ["pods", "pods/exec", "persistentvolumeclaims"]
      verb     = ["create", "delete", "deletecollection", "patch", "update"]
    }
  ]
}

variable "kr_casc_reload_name" {
  default = "jenkins-casc-reload"
}

variable "kr_casc_reload_rules" {
  default = [
    {
      api_grps = [""]
      res      = ["configmaps"]
      verb     = ["get", "watch", "list"]
    }
  ]
}

variable "rb_schedule_agents_name" {
  default = "jenkins-schedule-agents"
}

variable "rb_schedule_agents_ag" {
  default = "rbac.authorization.k8s.io"
}

variable "rb_schedule_agents_rf_kind" {
  default = "Role"
}

variable "rb_schedule_agents_sub_kind" {
  default = "ServiceAccount"
}

variable "rb_watch_configmaps_name" {
  default = "jenkins-watch-configmaps"
}


# PersistentVolume variables
variable "pv_name" {
  default = "jenkins-pv"
}

variable "pv_access_mode" {
  default = ["ReadWriteOnce"]
}

variable "pv_size" {
  default = "10Gi"
}

variable "pv_reclaim_policy" {
  default = "Retain"
}

variable "pv_path" {
  default = "/data/jenkins-volume/"
}


# PersistentVolumeClaim variables
variable "pvc_name" {
  default = "jenkins-pvc"
}

variable "pvc_accessModes" {
  default = ["ReadWriteOnce"]
}

variable "pvc_storage_size" {
  default = "8Gi"
}


# ConfigMap variables
variable "cmc_name" {
  default = "jenkins-config"
}

variable "cmc_label_component" {
  default = "jenkins-controller"
}

variable "cmj_name" {
  default = "jenkins-jcasc-config"
}


# Secrets variables
variable "secrets_name" {
  default = "jenkins-creds"
}

variable "secret_type" {
  default = "Opaque"
}

variable "jenkins_admin_user" {
  default = "admin"
}


# Service agent variables
variable "svc_name_agent" {
  default = "jenkins-agent"
}

variable "svc_type_agent" {
  default = "ClusterIP"
}

variable "svc_port_name_agent" {
  default = "agent-listener"
}

variable "svc_port_agent" {
  default = 50000
}

variable "svc_target_port_agent" {
  default = 50000
}


# Service controller variables
variable "svc_controller" {
  default = "jenkins-controller"
}

variable "svc_type_controller" {
  default = "NodePort"
}

variable "svc_port_name_controller" {
  default = "http"
}

variable "svc_port_controller" {
  default = 8080
}

variable "svc_target_port_controller" {
  default = 8080
}

variable "svc_nodeport_controller" {
  default = "30080"
}


# StateFullSets variable
variable "sts_name_controller" {
  default = "jenkins-sts"
}

variable "sts_replicas_controller" {
  default = 1
}

variable "sts_sc_rau_controller" {
  default = 1000
}

variable "sts_sc_fg_controller" {
  default = 1000
}

variable "sts_sc_ranr_controller" {
  default = true
}

variable "sts_init_container_name" {
  default = "jenkins-init"
}

variable "sts_image_controller" {
  default = "jenkins/jenkins:2.346.2-jdk11"
}

variable "sts_ic_ipp_controller" {
  default = "IfNotPresent"
}

variable "sts_ic_sc_ape_controller" {
  default = false
}

variable "sts_ic_sc_rorf_controller" {
  default = true
}

variable "sts_ic_command_controller" {
  default = ["sh", "/var/jenkins_config/apply_config.sh"]
}

variable "sts_ic_rr_cpu_controller" {
  default = "50m"
}

variable "sts_ic_rr_ram_controller" {
  default = "256Mi"
}

variable "sts_ic_rl_cpu_controller" {
  default = "2000m"
}

variable "sts_ic_rl_ram_controller" {
  default = "4096Mi"
}

variable "sts_ic_vm_controller" {
  default = [
    {
      name   = "jenkins-home"
      m_path = "/var/jenkins_home"
    },
    {
      name   = "jenkins-config"
      m_path = "/var/jenkins_config"
    },
    {
      name   = "plugins"
      m_path = "/usr/share/jenkins/ref/plugins"
    },
    {
      name   = "plugin-dir"
      m_path = "/var/jenkins_plugins"
    },
    {
      name   = "tmp-volume"
      m_path = "/tmp"
    }
  ]
}

variable "sts_con_name_controller" {
  default = "jenkins-controller"
}

variable "sts_con_ipp_controller" {
  default = "IfNotPresent"
}

variable "sts_con_args_controller" {
  default = ["--httpPort=8080"]
}

variable "sts_con_env_controller" {
  default = [
    {
      name  = "SECRETS"
      value = "/run/secrets/additional"
    },
    {
      name  = "JAVA_OPTS"
      value = "-Dcasc.reload.token=$(POD_NAME)"
    },
    {
      name  = "JENKINS_OPTS"
      value = "--webroot=/var/jenkins_cache/war"
    },
    {
      name  = "JENKINS_SLAVE_AGENT_PORT"
      value = "50000"
    },
    {
      name  = "CASC_JENKINS_CONFIG"
      value = "/var/jenkins_home/casc_configs"
    }
  ]
}

variable "sts_con_ports_controller" {
  default = [
    {
      name = "http"
      port = 8080
    },
    {
      name = "agent-listener"
      port = 50000
    }
  ]
}

variable "sts_con_sp_failureThreshold" {
  default = 12
}

variable "sts_con_sp_periodSeconds" {
  default = 10
}

variable "sts_con_sp_timeoutSeconds" {
  default = 5
}

variable "sts_con_sp_path" {
  default = "/login"
}

variable "sts_con_sp_portname" {
  default = "http"
}

variable "sts_con_lp_failureThreshold" {
  default = 5
}

variable "sts_con_lp_path" {
  default = "/login"
}

variable "sts_con_lp_portname" {
  default = "http"
}

variable "sts_con_lp_periodSeconds" {
  default = 10
}

variable "sts_con_lp_timeoutSeconds" {
  default = 5
}

variable "sts_con_rp_failureThreshold" {
  default = 3
}

variable "sts_con_rp_path" {
  default = "/login"
}

variable "sts_con_rp_portname" {
  default = "http"
}

variable "sts_con_rp_periodSeconds" {
  default = 10
}

variable "sts_con_rp_timeoutSeconds" {
  default = 5
}

variable "sts_con_rr_cpu_controller" {
  default = "50m"
}

variable "sts_con_rr_ram_controller" {
  default = "256Mi"
}

variable "sts_con_rl_cpu_controller" {
  default = "2000m"
}

variable "sts_con_rl_ram_controller" {
  default = "4096Mi"
}

variable "sts_con_vm_controller" {
  default = [
    {
      name       = "jenkins-home"
      mount_path = "/var/jenkins_home"
    },
    {
      name       = "jenkins-config"
      mount_path = "/var/jenkins_config"
    },
    {
      name       = "plugin-dir"
      mount_path = "/usr/share/jenkins/ref/plugins"
    },
    {
      name       = "sc-config-volume"
      mount_path = "/var/jenkins_home/casc_configs"
    },
    {
      name       = "jenkins-secrets"
      mount_path = "/run/secrets/additional"
    },
    {
      name       = "jenkins-cache"
      mount_path = "/var/jenkins_cache"
    },
    {
      name       = "tmp-volume"
      mount_path = "/tmp"
    }
  ]
}

variable "sts_con_name_cr" {
  default = "config-reload"
}

variable "sts_con_image_cr" {
  default = "kiwigrid/k8s-sidecar:1.15.0"
}

variable "sts_con_ipp_cr" {
  default = "IfNotPresent"
}

variable "sts_con_env_cr" {
  default = [
    {
      name  = "FOLDER"
      value = "/var/jenkins_home/casc_configs"
    },
    {
      name  = "LABEL"
      value = "jenkins-config"
    },
    {
      name  = "NAMESPACE"
      value = "jenkins"
    },
    {
      name  = "REQ_URL"
      value = "http://localhost:8080/reload-configuration-as-code/?casc-reload-token=$(POD_NAME)"
    },
    {
      name  = "REQ_METHOD"
      value = "POST"
    },
    {
      name  = "REQ_RETRY_CONNECT"
      value = "10"
    }
  ]
}

variable "sts_con_vm_cr" {
  default = [
    {
      name       = "sc-config-volume"
      mount_path = "/var/jenkins_home/casc_configs"
    },
    {
      name       = "jenkins-home"
      mount_path = "/var/jenkins_home"
    }
  ]
}

variable "sts_vols" {
  default = [
    {
      name     = "plugins"
      emptyDir = "{}"
    },
    {
      name     = "plugin-dir"
      emptyDir = "{}"
    },
    {
      name     = "jenkins-cache"
      emptyDir = "{}"
    },
    {
      name     = "sc-config-volume"
      emptyDir = "{}"
    },
    {
      name     = "tmp-volume"
      emptyDir = "{}"
    }
  ]
}


# IngressController variables
variable "ingress_name" {
  default = "janking-ingress"
}

variable "ingress_domain" {
  default = "jenkins.loc"
}

variable "inrgress_path_type" {
  default = "Prefix"
}

variable "ingress_path" {
  default = "/"
}
