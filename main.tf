terraform {
  required_version = ">= 0.12"
}

output "endpoint" {
  value = "${var.PROXMOX_VE_ENDPOINT}"
}

output "password" {
  value = "${var.PROXMOX_VE_PASSWORD}"
}

output "username" {
  value = "${var.PROXMOX_VE_USERNAME}"
}

output "ssh_node_address" {
  value = "${var.PROXMOX_VE_SSH_NODE_ADDRESS}"
}

output "ssh_node_name" {
  value = "${var.PROXMOX_VE_SSH_NODE_NAME}"
}