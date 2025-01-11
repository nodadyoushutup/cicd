terraform {
  required_providers {
    linux = {
      source = "TelkomIndonesia/linux"
    }
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "linux" {
  host = local.config.data.development.ip_address.external
  port = local.config.data.development.port.external
  user = local.config.data.development.username
  password = local.config.data.development.password
  # private_key = file(local.config.data.development.private_key)
}

provider "proxmox" {
  endpoint = "${local.config.data.proxmox.endpoint.protocol}://${local.config.data.proxmox.endpoint.ip_address}:${local.config.data.proxmox.endpoint.port}"
  insecure  = local.config.data.proxmox.endpoint.insecure
  password = local.config.data.proxmox.auth.password
  username = "${local.config.data.proxmox.auth.username}@${local.config.data.proxmox.auth.realm}"
  random_vm_ids = true
  ssh {
    agent = local.config.data.proxmox.ssh.agent.enabled
    agent_socket = local.config.data.proxmox.ssh.agent.socket
    private_key = coalesce(try(file(local.config.data.proxmox.ssh.private_key), null), local.default.private_key)
    node {
      name = local.config.data.proxmox.ssh.node.name
      address = local.config.data.proxmox.ssh.node.address
      port = local.config.data.proxmox.ssh.node.port
    }
  }
}