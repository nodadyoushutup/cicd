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
}