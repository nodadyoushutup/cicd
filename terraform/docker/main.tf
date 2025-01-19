locals {
  java_opts = [
    "-Djenkins.install.runSetupWizard=false"
  ]
  github_auth = templatefile(
    "${path.module}/github_auth.groovy.tpl", 
    {
      GITHUB_USERNAME = var.GITHUB_USERNAME, 
      GITHUB_JENKINS_CLIENT_ID = var.GITHUB_JENKINS_CLIENT_ID, 
      GITHUB_JENKINS_CLIENT_SECRET = var.GITHUB_JENKINS_CLIENT_SECRET 
    }
  )
}

resource "null_resource" "create_remote_file" {
  depends_on = [data.template_file.github_auth]
  connection {
    type        = "ssh"
    user        = var.VIRTUAL_MACHINE_USERNAME
    private_key = file(var.SSH_PRIVATE_KEY)
    host        = var.PROXMOX_VE_SSH_NODE_ADDRESS
    port        = 10122
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/init.groovy.d",
      "chown ubuntu:ubuntu /home/ubuntu/init.groovy.d",
      "echo '${local.github_auth}' > /tmp/github_auth.groovy"
      # "cp /tmp/github_auth.groovy /home/ubuntu/github_auth.groovy"
    ]
  }
}

resource "docker_image" "jenkins" {
  depends_on = [null_resource.create_remote_file]
  name = "ghcr.io/nodadyoushutup/jenkins:2.493"
}

resource "docker_volume" "jenkins" {
  depends_on = [docker_image.jenkins]
  name = "jenkins"
}

resource "docker_container" "jenkins" {
  depends_on = [docker_volume.jenkins]
  name  = "jenkins"
  image = docker_image.jenkins.image_id
  env = ["JAVA_OPTS=${join(" ", local.java_opts)}"]
  restart = "unless-stopped"
  start = true
  
  ports {
    internal = "8080"
    external = "8080"
  }

  volumes {
    volume_name = docker_volume.jenkins.name
    container_path = "/var/jenkins_home"
  }

  volumes {
    container_path = "/usr/share/jenkins/ref/init.groovy.d"
    host_path = "/home/ubuntu/init.groovy.d"
  }

  healthcheck {
    test = ["http://localhost:8080/whoAmI/api/json?tree=authenticated"]
  }

}