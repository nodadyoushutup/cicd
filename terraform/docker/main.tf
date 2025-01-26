# locals {
#   java_opts = [
#     "-Djenkins.install.runSetupWizard=false"
#   ]
#   template = {
#     groovy = {
#       auth = templatefile(
#         "${path.module}/template/auth.groovy.tpl", 
#         {
#           GITHUB_USERNAME = var.GITHUB_USERNAME, 
#           GITHUB_JENKINS_CLIENT_ID = var.GITHUB_JENKINS_CLIENT_ID, 
#           GITHUB_JENKINS_CLIENT_SECRET = var.GITHUB_JENKINS_CLIENT_SECRET 
#         }
#       )
#       system = templatefile(
#         "${path.module}/template/system.groovy.tpl", 
#         {
#           JENKINS_URL = var.JENKINS_URL
#         }
#       )
#       agent = templatefile(
#         "${path.module}/template/agent.groovy.tpl", 
#         {}
#       )
#     }
    
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
#       jenkins = [
#         "mkdir -p /home/${var.VIRTUAL_MACHINE_USERNAME}/secret",
#         "chown ${var.VIRTUAL_MACHINE_USERNAME}:${var.VIRTUAL_MACHINE_USERNAME} /home/${var.VIRTUAL_MACHINE_USERNAME}/secret",
#         "mkdir -p /home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d",
#         "chown ${var.VIRTUAL_MACHINE_USERNAME}:${var.VIRTUAL_MACHINE_USERNAME} /home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d",
#         "cat <<EOF > /tmp/auth.groovy",
#         "${local.template.groovy.auth}",
#         "EOF",
#         "cat <<EOF > /tmp/system.groovy",
#         "${local.template.groovy.system}",
#         "EOF",
#         "cat <<EOF > /tmp/agent.groovy",
#         "${local.template.groovy.agent}",
#         "EOF",
#         "cp /tmp/auth.groovy /home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d/auth.groovy",
#         "cp /tmp/system.groovy /home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d/system.groovy",
#         "cp /tmp/agent.groovy /home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d/agent.groovy",
#         "chown -R ${var.VIRTUAL_MACHINE_USERNAME}:${var.VIRTUAL_MACHINE_USERNAME} /home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d",
#         "rm -rf /tmp/auth.groovy",
#         "rm -rf /tmp/system.groovy",
#         "rm -rf /tmp/agent.groovy"
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
#     inline = local.exec.inline.jenkins
#   }
# }

# resource "docker_image" "jenkins" {
#   depends_on = [null_resource.exec]
#   name = "ghcr.io/nodadyoushutup/jenkins-controller:2.494"
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
#   wait = true
  
#   ports {
#     internal = "8080"
#     external = "8080"
#   }

#   ports {
#     internal = "50000"
#     external = "50000"
#   }

#   volumes {
#     volume_name = docker_volume.jenkins.name
#     container_path = "/var/jenkins_home"
#   }

#   volumes {
#     container_path = "/usr/share/jenkins/ref/init.groovy.d"
#     host_path = "/home/${var.VIRTUAL_MACHINE_USERNAME}/init.groovy.d"
#   }

#   volumes {
#     container_path = "/secret"
#     host_path = "/home/${var.VIRTUAL_MACHINE_USERNAME}/secret"
#   }

#   healthcheck {
#     test = ["http://localhost:8080/whoAmI/api/json?tree=authenticated"]
#   }

# }

# data "external" "agent_secret" {
#   depends_on = [docker_container.jenkins]
#   program = [
#     "${path.module}/script/fetch_agent_secret.sh",
#     local.exec.connection.host,
#     local.exec.connection.user,
#     var.SSH_PRIVATE_KEY,
#     local.exec.connection.port
#   ]
# }

# output "agent_secret" {
#   depends_on = [ data.external.agent_secret ]
#   value = data.external.agent_secret.result.secret
# }

# resource "docker_image" "agent" {
#   depends_on = [data.external.agent_secret]
#   name = "ghcr.io/nodadyoushutup/jenkins-agent:3283.v92c105e0f819-7"
# }

# resource "docker_volume" "agent" {
#   depends_on = [docker_image.agent]
#   name = "agent"
# }

# resource "docker_container" "agent" {
#   depends_on = [docker_volume.agent]
#   name  = "agent"
#   image = docker_image.agent.image_id
#   env = [
#     "JENKINS_URL=http://192.168.1.101:8080",
#     "JENKINS_SECRET=${data.external.agent_secret.result.secret}",
#     "JENKINS_AGENT_NAME=simple-agent"
#   ]
#   restart = "unless-stopped"
#   init = true
# }