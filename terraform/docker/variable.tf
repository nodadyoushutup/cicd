variable "SSH_PRIVATE_KEY" {
  type = string
  default = null
}

variable "PROXMOX_VE_ENDPOINT" {
  type = string
  default = null
}

variable "PROXMOX_VE_PASSWORD" {
  type = string
  default = null
}

variable "PROXMOX_VE_USERNAME" {
  type = string
  default = null
}

variable "PROXMOX_VE_SSH_USERNAME" {
  type = string
  default = null
}

variable "PROXMOX_VE_SSH_NODE_ADDRESS" {
  type = string
  default = null
}

variable "PROXMOX_VE_SSH_NODE_NAME" {
  type = string
  default = null
}

variable "VIRTUAL_MACHINE_USERNAME" {
  type = string
  default = null
}

variable "GITCONFIG" {
  type = string
  default = null
}

variable "NAS_LOCAL_IP" {
  type = string
  default = null
}

variable "NAS_NFS_MEDIA" {
  type = string
  default = null
}

variable "GITHUB_USERNAME" {
  type = string
  default = null
}

variable "GITHUB_JENKINS_CLIENT_ID" {
  type = string
  default = null
}

variable "GITHUB_JENKINS_CLIENT_SECRET" {
  type = string
  default = null
}

variable "JENKINS_URL" {
  type = string
  default = null
}