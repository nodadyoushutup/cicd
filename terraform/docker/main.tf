# locals {
#   java_opts = [
#     "-Djenkins.install.runSetupWizard=false"
#   ]
# }

# resource "docker_image" "jenkins" {
#   name = "ghcr.io/nodadyoushutup/jenkins:2.493"
# }

# resource "docker_volume" "jenkins" {
#   depends_on = [docker_image.jenkins]
#   name = "jenkins"
# }

# resource "docker_container" "jenkins" {
#   depends_on = [docker_volume.jenkins]
#   name  = "jenkins"
#   image = docker_image.jenkins.image_id
#   env = ["JAVA_OPTS=${join(" ", local.java_opts)}"]
#   restart = "unless-stopped"
#   start = false
  
#   ports {
#     internal = "8080"
#     external = "8080"
#   }

#   volumes {
#     volume_name = docker_volume.jenkins.name
#     container_path = "/var/jenkins_home"
#   }

#   volumes {
#     container_path = "/usr/share/jenkins/ref/init.groovy.d"
#     host_path = "/home/ubuntu/init.groovy.d"
#   }

#   healthcheck {
#     test = ["http://localhost:8080/whoAmI/api/json?tree=authenticated"]
#   }

# }