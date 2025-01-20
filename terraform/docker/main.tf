# locals {
#   java_opts = [
#     "-Djenkins.install.runSetupWizard=false"
#   ]
#   template = {
#     auth_groovy = templatefile(
#       "${path.module}/auth.groovy.tpl", 
#       {
#         GITHUB_USERNAME = var.GITHUB_USERNAME, 
#         GITHUB_JENKINS_CLIENT_ID = var.GITHUB_JENKINS_CLIENT_ID, 
#         GITHUB_JENKINS_CLIENT_SECRET = var.GITHUB_JENKINS_CLIENT_SECRET 
#       }
#     )
#     system_groovy = templatefile(
#       "${path.module}/system.groovy.tpl", 
#       {
#         JENKINS_URL = var.JENKINS_URL
#       }
#     )
#   }
#   exec = {
#     connection = {
#       type = "ssh"
#       user = var.VIRTUAL_MACHINE_USERNAME
#       private_key = file(var.SSH_PRIVATE_KEY)
#       host = var.PROXMOX_VE_SSH_NODE_ADDRESS
#       port = 10122
#     }
#     inline = {
#       init_jenkins = [
#         "mkdir -p /home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d",
#         "chown ${var.VIRTUAL_MACHINE_USERNAME}:${var.VIRTUAL_MACHINE_USERNAME} /home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d",
#         "cat <<EOF > /tmp/auth.groovy",
#         "${local.template.auth_groovy}",
#         "EOF",
#         "cat <<EOF > /tmp/system.groovy",
#         "${local.template.system_groovy}",
#         "EOF",
#         "cp /tmp/auth.groovy /home/${var.VIRTUAL_MACHINE_USERNAME}/auth.groovy",
#         "cp /tmp/system.groovy /home/${var.VIRTUAL_MACHINE_USERNAME}/system.groovy"
#       ]
#     }
#   }
# }

# resource "null_resource" "exec" {
#   triggers = {
#     always_run = timestamp()
#   }
  
#   connection {
#     type = local.exec.connection.type
#     user = local.exec.connection.user
#     private_key = local.exec.connection.private_key
#     host = local.exec.connection.host
#     port = local.exec.connection.port
#   }

#   provisioner "remote-exec" {
#     inline = local.exec.inline.init_jenkins
#   }
# }

# resource "docker_image" "jenkins" {
#   depends_on = [null_resource.exec]
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
#   start = true
  
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