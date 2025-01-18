resource "docker_image" "jenkins" {
  name = "ghcr.io/nodadyoushutup/jenkins:2.493"
}

resource "docker_volume" "jenkins" {
  depends_on = [docker_image.jenkins]
  name = "jenkins"
}

resource "docker_container" "jenkins" {
  depends_on = [docker_volume.jenkins]
  name  = "jenkins"
  image = docker_image.ubuntu.jenkins
  ports = {
    internal = "8080"
    external = "8080"
  }
}