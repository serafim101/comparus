resource "random_password" "password" {
  length  = 16
  special = false
  #override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "creds" {
  metadata {
    name      = var.secrets_name
    namespace = kubernetes_namespace.jenkins_ns.metadata[0].name
    labels = {
      "app.kubernetes.io/name"      = var.label_name
      "app.kubernetes.io/component" = var.label_component
    }
  }

  type = var.secret_type
  data = {
    "jenkins-admin-user"     = var.jenkins_admin_user
    "jenkins-admin-password" = random_password.password.result
  }
}
