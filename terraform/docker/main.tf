locals {
  java_opts = [
    "-Djenkins.install.runSetupWizard=false"
  ]
}

data "template_file" "github_auth" {
  template = <<EOF
This is a dynamic file content:
Key = "${var.NAS_LOCAL_IP}"
EOF
}

resource "null_resource" "create_remote_file" {
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
      "echo \"${data.template_file.github_auth.rendered}\" > /tmp/github_auth.groovy",
      # "cp /tmp/github_auth.groovy /home/ubuntu/github_auth.groovy"
    ]
  }
}

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