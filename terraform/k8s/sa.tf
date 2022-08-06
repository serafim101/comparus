resource "kubernetes_service_account" "jenkins_sa" {
  metadata {
    name      = var.sa_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
  }
}

resource "kubernetes_cluster_role" "jenkins_cr" {
  metadata {
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
    name = var.cr_name
  }

  rule {
    api_groups = var.cr_api_groups
    resources  = var.cr_resources
    verbs      = var.cr_verbs
  }

  rule {
    api_groups = var.cr_api_groups_2
    resources  = var.cr_resources_2
    verbs      = var.cr_verbs_2
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_rb" {
  metadata {
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
    name      = var.rb_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins_cr.metadata[0].name
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "system:serviceaccounts:${kubernetes_service_account.jenkins_sa.metadata[0].name}"
  }
}
