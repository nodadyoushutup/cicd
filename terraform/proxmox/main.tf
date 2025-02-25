locals {
  template = {
    gitconfig = templatefile(
      "${path.module}/template/.gitconfig.tpl", 
      {}
    )
    private_key = templatefile(
      "${path.module}/template/id_rsa.tpl", 
      {
        ID_RSA=file(var.SSH_PRIVATE_KEY)
      }
    )
  }

  exec = {
    connection = {
      type = "ssh"
      user = var.VIRTUAL_MACHINE_USERNAME
      private_key = file(var.SSH_PRIVATE_KEY)
      host = var.PROXMOX_VE_SSH_NODE_ADDRESS
      port = 10122
    }
    inline = {
      hostname = [
        "sudo hostnamectl set-hostname cicd",
        "sudo systemctl restart systemd-hostnamed"
      ]
      gitconfig = [
        "cat <<EOF > /tmp/.gitconfig",
        "${local.template.gitconfig}",
        "EOF",
        "cp -p /tmp/.gitconfig /home/${var.VIRTUAL_MACHINE_USERNAME}/.gitconfig",
        "chown ${var.VIRTUAL_MACHINE_USERNAME}:${var.VIRTUAL_MACHINE_USERNAME} /home/${var.VIRTUAL_MACHINE_USERNAME}/.gitconfig",
        "rm -rf /tmp/.gitconfig",
      ]
      private_key = [
        "cat <<EOF > /tmp/id_rsa",
        "${local.template.private_key}",
        "EOF",
        "chmod 600 /tmp/id_rsa",
        "cp -p /tmp/id_rsa /home/${var.VIRTUAL_MACHINE_USERNAME}/.ssh/id_rsa",
        "chown ${var.VIRTUAL_MACHINE_USERNAME}:${var.VIRTUAL_MACHINE_USERNAME} /home/${var.VIRTUAL_MACHINE_USERNAME}/.ssh/id_rsa",
        "chmod 600 /home/${var.VIRTUAL_MACHINE_USERNAME}/.ssh/id_rsa",
        "rm -rf /tmp/id_rsa",
      ]
    }
  }
}

resource "proxmox_virtual_environment_file" "cicd_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    groups:
      - docker: [${var.VIRTUAL_MACHINE_USERNAME}]
    users:
      - default
      - name: ${var.VIRTUAL_MACHINE_USERNAME}
        groups: sudo
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
    mounts:
      - ["${var.NAS_LOCAL_IP}:${var.NAS_NFS_MEDIA}", "${var.NAS_NFS_MEDIA}", "nfs", "defaults,nofail", "0", "2"]
    runcmd:
      - su - ${var.VIRTUAL_MACHINE_USERNAME} -c "ssh-import-id gh:${var.GITHUB_USERNAME}"
      - mkdir -p ${var.NAS_NFS_MEDIA}
      - chown ${var.VIRTUAL_MACHINE_USERNAME}:${var.VIRTUAL_MACHINE_USERNAME} ${var.NAS_NFS_MEDIA}
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cicd-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "cicd" {
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
                address = "192.168.1.102/24"
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

    # pool_id = "cicd"

    started = true

    startup {
        order = 2
        up_delay = 0
        down_delay = 0
    }

    tags = ["terraform", "cloud-image", "cicd"]

    stop_on_destroy = true

    vga {
        memory = 16
        type = "qxl"
        clipboard = "vnc"
    }

    vm_id = 1101
}

resource "null_resource" "exec" {
  depends_on = [ proxmox_virtual_environment_vm.cicd ]
  triggers = {
    always_run = timestamp()
  }
  
  connection {
    type = local.exec.connection.type
    user = local.exec.connection.user
    private_key = local.exec.connection.private_key
    host = local.exec.connection.host
    port = local.exec.connection.port
  }

  provisioner "remote-exec" {
    inline = concat(
      local.exec.inline.hostname, 
      local.exec.inline.gitconfig,
      local.exec.inline.private_key
    )
  }
}
