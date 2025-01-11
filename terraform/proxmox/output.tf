data "proxmox_virtual_environment_pools" "available_pools" {}

output "root" {
  value = data.proxmox_virtual_environment_pools
}
