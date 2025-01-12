data "local_file" "ssh_public_key" {
  filename = var.GITCONFIG
}

data "local_file" "ssh_private_key" {
  filename = var.SSH_PRIVATE_KEY
}

data "local_file" "gitconfig" {
  filename = var.SSH_PUBLIC_KEY
}

resource "proxmox_virtual_environment_file" "cicd_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: cicd
    groups:
      - docker: [ubuntu]
    users:
      - default
      - name: ubuntu
        groups: sudo
        ssh_authorized_keys:
          - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgZOVI9Sgx6OlHbV3HobrJwodrDl6B7mqXzk8tP565mi1qtHDC89bkrD+ZB3Z2jbfg6H8buipV1NH6nnpBNMKedM9YRcDJvEj9NqPBdEvEQ7+pz7rTia6nNjQA/kACvyCJiiRm9xY3UXz94eVtfRJNxhedkg7A+MeJI8cmraRkFQ0Y+D9fvTHlo8xzNcY8Qg5ONOA/RcN/CfKR2RZntxuKd4VkeaUEqzJQpWOhAD12UWR6puEbxSj0KtWROtmGiXaLvaZ0t8bhjpc3a3hDQdCaCtdNeHPG9mbuZymCvvM/Hvg+Jq/bkuRgjPE+O5xC5QsUlBf32JdqatklT9z6trxZSkbyJvHSxtVzyEKMWB+sUJZTnV0c+dKybvXdT87cpl80O5BnsPbIZ2UIu21dY8ngice/rgT/bmYNvbw0ibfTfyfkY977NRUG6OUxoL/aBqTDAdOSS3fEWeM7TyO/rTk142f2GdqHWzozksVgxRu/ZjtmqahIXQrduNFF4kYs+WE= jacob@Desktop
        ssh_import_id:
          - gh:nodadyoushutup
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cicd-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "development" {
    depends_on = [
        # proxmox_virtual_environment_download_file.cloud_image,
        proxmox_virtual_environment_file.cicd_cloud_config
    ]
    
    # REQUIRED
    ################################################
    node_name = "pve"

    # OPTIONAL
    ################################################
    agent {
        enabled = true
        timeout = "5m"
        trim = false
        type = "virtio"
    }

    audio_device {
        device = "intel-hda"
        driver = "spice"
        enabled = true
    }

    bios = "ovmf"

    boot_order = ["scsi0"]

    cpu {
        # architecture = "x86_64" # Can only be set running terraform as root
        cores = 4
        flags = ["+aes"]
        hotplugged = 0
        limit = 0
        numa = false
        sockets = 1
        type = "x86-64-v2-AES"
        units = 1024
        affinity = null
    }

    description = "cicd"

    disk {
        aio = "io_uring"
        backup = true
        cache = "none"
        datastore_id = "virtualization"
        path_in_datastore = null
        discard = "on"
        file_format = "raw"
        file_id = "local:iso/cloud_image_x86_64_jammy.img"
        interface = "scsi0"
        iothread = false
        replicate = true
        serial = null
        size = 10
        # speed = {
        #     iops_read = null 
        #     iops_read_burstable = null
        #     iops_write = null
        #     iops_write_burstable = null
        #     read = null
        #     read_burstable = null
        #     write = null
        #     write_burstable = null
        # }
        ssd = true
    }

    efi_disk {
        datastore_id = "virtualization"
        file_format = "raw"
        type = "4m"
        pre_enrolled_keys = false
    }

    initialization {
        datastore_id = "virtualization"
        user_data_file_id = proxmox_virtual_environment_file.cicd_cloud_config.id
        
        ip_config {
            ipv4 {
                address = "192.168.1.101/24"
                gateway = "192.168.1.1"
            }
            ipv6 {
                address = "dhcp"
            }
        }
    }

    machine = "q35"

    memory {
        dedicated = 16384
        floating = 0
        shared = 0
        hugepages = null
        keep_hugepages = null
    }

    name = "cicd"

    network_device {
        bridge = "vmbr0"
        disconnected = false
        enabled = true
        firewall = false
        mac_address = "0a:00:00:00:11:01"
        model = "virtio"
        mtu = null
        queues = null
        rate_limit = null
        vlan_id = null
        trunks = null
    }

    on_boot = true

    operating_system {
        type = "l26"
    }

    pool_id = "development"

    started = true

    startup {
        order = 2
        up_delay = 0
        down_delay = 0
    }

    tags = ["terraform", "cloud-image", "development"]

    stop_on_destroy = true

    vga {
        memory = 16
        type = "qxl"
        clipboard = "vnc"
    }

    vm_id = 1101
}

