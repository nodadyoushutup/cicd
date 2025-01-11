# resource "random_id" "trigger" {
#   byte_length = 8
# }

# data "local_file" "ssh_public_key" {
#   for_each = toset(local.public_key)
#   filename = each.value
# }

# output "ssh_public_key" {
#   value = data.local_file.ssh_public_key
# }