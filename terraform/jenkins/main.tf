terraform {
  required_providers {
    jenkins = {
      source  = "yarlson/jenkins"
      version = "0.9.10"
    }
  }
}

provider "jenkins" {
  server_url = var.jenkins_url
  username   = var.jen_user
  password   = var.jen_pass
}
