terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host     = "ssh://${var.VIRTUAL_MACHINE_USERNAME}@${var.PROXMOX_VE_SSH_NODE_ADDRESS}:10122"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "-o", "IdentityFile=/mnt/workspace/id_rsa"]

  registry_auth {
    address  = "https://index.docker.io/v1/"
    username = "nodadyoushutup"
    password = var.VIRTUAL_MACHINE_PASSWORD
  }
}