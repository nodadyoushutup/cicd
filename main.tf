// main.tf

terraform {
  required_version = ">= 0.12"
}

locals {
  hello_message = "Hello, world!"
}

output "hello" {
  value = "${var.PROXMOX_VE_ENDPOINT}"
}