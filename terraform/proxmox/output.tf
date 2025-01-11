locals {
  proxmox = jsondecode(var.proxmox)
}

output "proxmox_object" {
  value = local.proxmox
}