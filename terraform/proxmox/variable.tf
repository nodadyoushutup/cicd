variable "PROXMOX_VE_USERNAME" {
  type = string
  default = null
}

variable "PROXMOX_VE_PASSWORD" {
  type = string
  default = null
}

variable "PROXMOX_VE_ENDPOINT" {
  type = string
  default = null
}

variable "PROXMOX_VE_SSH_NODE_ADDRESS" {
  type = string
  default = null
}

variable "VIRTUAL_MACHINE_USERNAME" {
  type = string
  default = null
}

variable "SSH_PRIVATE_KEY" {
  type = string
  default = null
}

variable "SSH_PUBLIC_KEY" {
  type = string
  default = null
}

variable "GITCONFIG" {
  type = string
  default = null
}

variable "proxmox" {
  type = object({
    username = string
    password = string
    endpoint = string
    ssh_node_address = string
  })
  default = null
}