terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint = var.PROXMOX_VE_ENDPOINT
  password = "terraform"
  username = "terraform@pve"
  random_vm_ids = true
  insecure = true
}