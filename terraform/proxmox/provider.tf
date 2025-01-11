terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

variable "proxmox" {
  type    = string
  default = null
}