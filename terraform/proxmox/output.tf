data "proxmox_virtual_environment_user" "root" {
  user_id = "root@pve"
}

output "root" {
  value = var.PROXMOX_VE_ENDPOINT
}
