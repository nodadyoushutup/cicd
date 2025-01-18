terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.PROXMOX_VE_ENDPOINT
  password = var.PROXMOX_VE_PASSWORD
  username = var.PROXMOX_VE_USERNAME
  random_vm_ids = true
  insecure = true
  ssh {
    agent = true
    node {
      name    = var.PROXMOX_VE_SSH_NODE_NAME
      address = var.PROXMOX_VE_SSH_NODE_ADDRESS
    }
  }
}

provider "docker" {
  host     = "ssh://${var.VIRTUAL_MACHINE_USERNAME}@${var.PROXMOX_VE_SSH_NODE_ADDRESS}:1022"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "-o", "IdentityFile=/mnt/workspace/id_rsa"]
}