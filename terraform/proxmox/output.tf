data "proxmox_virtual_environment_user" "root" {
  user_id = "root@pve"
}

output "root" {
  value = data.proxmox_virtual_environment_user.id
}