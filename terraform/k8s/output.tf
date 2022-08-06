output "jenkins_url" {
  description = "Jenkins server URL"
  value       = "http://${kubernetes_ingress_v1.jenkins-ingress.status[0].load_balancer[0].ingress[0].ip}:${kubernetes_service.controller.spec[0].port[0].node_port}"
}

output "jenkins_user" {
  description = "Jenkins server admin user"
  sensitive   = true
  value       = kubernetes_secret.creds.data.jenkins-admin-user
}

output "jenkins_password" {
  description = "Jenkins server admin-user password"
  sensitive   = true
  value       = kubernetes_secret.creds.data.jenkins-admin-password
}
