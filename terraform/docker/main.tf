data "docker_image" "nginx" {
  depends_on = [ proxmox_virtual_environment_vm.cicd ]
  name = "nginx:1.17.6"
}