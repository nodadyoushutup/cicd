terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint = var.PROXMOX_VE_ENDPOINT
  password = var.PROXMOX_VE_PASSWORD
  username = var.PROXMOX_VE_USERNAME
  random_vm_ids = true
  insecure = false
  ssh {
    agent = true
    username = "root"
    private_key = file(var.SSH_PRIVATE_KEY)
  }
}