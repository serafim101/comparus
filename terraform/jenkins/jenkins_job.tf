resource "jenkins_folder" "job_folder" {
  name = var.job_folder
}

resource "jenkins_job" "job" {
  name   = var.jen_job_name
  folder = jenkins_folder.job_folder.id
  template = templatefile("${path.module}/job.xml", {
    description = "An ${var.jen_job_name} job created from Terraform"
  })
}
