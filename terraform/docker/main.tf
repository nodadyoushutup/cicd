locals {
  java_opts = [
    "-Djenkins.install.runSetupWizard=false"
  ]
}

data "template_file" "example" {
  template = <<EOF
This is a dynamic file content:
Key = "value"
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
      "echo '${data.template_file.example.rendered}' > /tmp/example.txt"
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