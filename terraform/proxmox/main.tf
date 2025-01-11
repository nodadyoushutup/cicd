# resource "linux_file" "test" {
#     depends_on = [ proxmox_virtual_environment_vm.development ]
#     path = "/tmp/test.txt"
#     content = <<-EOF
#         hello world test
#     EOF
#     owner = 1000
#     group = 1000
#     mode = "777"
#     overwrite = true
# }

# resource "proxmox_virtual_environment_vm" "development" {
#     # depends_on = [
#     #     proxmox_virtual_environment_download_file.cloud_image,
#     #     # proxmox_virtual_environment_file.cloud_config
#     # ]
    
#     # REQUIRED
#     ################################################
#     node_name = local.config.data.proxmox.ssh.node.name

#     # OPTIONAL
#     ################################################
#     agent {
#         enabled = true
#         timeout = "5m"
#         trim = false
#         type = "virtio"
#     }

#     audio_device {
#         device = "intel-hda"
#         driver = "spice"
#         enabled = true
#     }

#     bios = "ovmf"

#     boot_order = ["scsi0"]

#     cpu {
#         # architecture = "x86_64" # Can only be set running terraform as root
#         cores = 2
#         flags = ["+aes"]
#         hotplugged = 0
#         limit = 0
#         numa = false
#         sockets = 1
#         type = "x86-64-v2-AES"
#         units = 1024
#         affinity = null
#     }

#     description = "module-debug"

#     disk {
#         aio = "io_uring"
#         backup = true
#         cache = "none"
#         datastore_id = local.config.data.proxmox.datastore.disk
#         path_in_datastore = null
#         discard = "on"
#         file_format = "raw"
#         file_id = "${local.config.data.proxmox.datastore.iso}:iso/cloud_image_x86_64_jammy.img"
#         interface = "scsi0"
#         iothread = false
#         replicate = true
#         serial = null
#         size = 10
#         # speed = {
#         #     iops_read = null 
#         #     iops_read_burstable = null
#         #     iops_write = null
#         #     iops_write_burstable = null
#         #     read = null
#         #     read_burstable = null
#         #     write = null
#         #     write_burstable = null
#         # }
#         ssd = true
#     }

#     efi_disk {
#         datastore_id = local.config.data.proxmox.datastore.disk
#         file_format = "raw"
#         type = "4m"
#         pre_enrolled_keys = false
#     }

#     initialization {
#         datastore_id = local.config.data.proxmox.datastore.disk
#         # user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
#         user_account {
#             keys = [for pk in data.local_file.ssh_public_key : pk.content]
#             password = local.config.data.development.password
#             username = local.config.data.development.username
#         }
#         ip_config {
#             ipv4 {
#                 address = "192.168.1.101/24"
#                 gateway = "192.168.1.1"
#             }
#             ipv6 {
#                 address = "dhcp"
#             }
#         }
#     }

#     machine = "q35"

#     memory {
#         dedicated = 16384
#         floating = 0
#         shared = 0
#         hugepages = null
#         keep_hugepages = null
#     }

#     name = "development"

#     network_device {
#         bridge = "vmbr0"
#         disconnected = false
#         enabled = true
#         firewall = false
#         mac_address = local.config.data.development.mac_address
#         model = "virtio"
#         mtu = null
#         queues = null
#         rate_limit = null
#         vlan_id = null
#         trunks = null
#     }

#     on_boot = true

#     operating_system {
#         type = "l26"
#     }

#     pool_id = "development"

#     startup {
#         order = 1
#         up_delay = 0
#         down_delay = 0
#     }

#     tags = ["terraform", "cloud-image", "development"]

#     stop_on_destroy = true

#     vga {
#         memory = 16
#         type = "qxl"
#         clipboard = "vnc"
#     }

#     vm_id = 1101
# }

