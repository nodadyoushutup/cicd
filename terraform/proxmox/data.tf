data "local_file" "ssh_public_key" {
  filename = var.GITCONFIG
}

data "local_file" "ssh_private_key" {
  filename = var.SSH_PRIVATE_KEY
}

data "local_file" "gitconfig" {
  filename = var.SSH_PUBLIC_KEY
}