resource "proxmox_virtual_environment_vm" "gateway" {
  name      = "k8s-gw"
  node_name = var.proxmox_name
  vm_id     = var.k8s_gateway_vm_id
  pool_id = var.proxmox_pool

  clone {
    vm_id = var.template_vm_id
    full  = false
  }

  # The QEMU Guest Agent used to retreive IP addresses and other info from the VM.
  agent {
    enabled = true
  }

  cpu {
    cores = var.k8s_gateway_cpu_cores
    type  = "x86-64-v2-AES"
  }
  
  memory {
    dedicated = var.k8s_gateway_memory
  } 

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
    mac_address = var.k8s_gateway_wan_mac_address
  }

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  initialization {
    datastore_id = var.proxmox_storage

    # Home Network
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    
    # Cluster Network (Internal)
    ip_config {
      ipv4 {
        address = var.k8s_gateway_ip
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_user.id
    meta_data_file_id = proxmox_virtual_environment_file.cloud_init_gateway_meta.id
  }
}
