resource "kubernetes_role" "kr_schedule-agents" {
  metadata {
    name      = var.kr_schedule_agent_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  dynamic "rule" {
    for_each = var.kr_schedule_agent_rules
    content {
      api_groups = rule.value.api_grps
      resources  = rule.value.res
      verbs      = rule.value.verb
    }
  }
}

resource "kubernetes_role" "kr_casc-reload" {
  metadata {
    name      = var.kr_casc_reload_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  dynamic "rule" {
    for_each = var.kr_casc_reload_rules
    content {
      api_groups = rule.value.api_grps
      resources  = rule.value.res
      verbs      = rule.value.verb
    }
  }
}


resource "kubernetes_role_binding" "rb_schedule-agents" {
  metadata {
    name      = var.rb_schedule_agents_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  role_ref {
    api_group = var.rb_schedule_agents_ag
    kind      = var.rb_schedule_agents_rf_kind
    name      = kubernetes_role.kr_schedule-agents.metadata[0].name
  }

  subject {
    kind      = var.rb_schedule_agents_sub_kind
    name      = kubernetes_service_account.jenkins_sa.metadata[0].name
    namespace = kubernetes_service_account.jenkins_sa.metadata[0].namespace
  }
}

resource "kubernetes_role_binding" "rb_watch-configmaps" {
  metadata {
    name      = var.rb_watch_configmaps_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  role_ref {
    api_group = var.rb_schedule_agents_ag
    kind      = var.rb_schedule_agents_rf_kind
    name      = kubernetes_role.kr_casc-reload.metadata[0].name
  }

  subject {
    kind      = var.rb_schedule_agents_sub_kind
    name      = kubernetes_service_account.jenkins_sa.metadata[0].name
    namespace = kubernetes_service_account.jenkins_sa.metadata[0].namespace
  }
}
