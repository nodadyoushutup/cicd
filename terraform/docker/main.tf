resource "docker_image" "jenkins" {
  name = "ghcr.io/nodadyoushutup/jenkins:2.493"
}

resource "docker_container" "jenkins" {
  name  = "jenkins"
  image = docker_image.ubuntu.jenkins
}