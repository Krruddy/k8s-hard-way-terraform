resource "proxmox_virtual_environment_vm" "controllers" {
  count     = var.k8s_ctrl_count
  name      = "k8s-ctrl-${count.index + 1}"
  node_name = var.proxmox_name
  vm_id     = var.k8s_ctrl_id_start + count.index + 1

  clone {
    vm_id = var.template_vm_id
    full  = false
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.k8s_ctrl_cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.k8s_ctrl_memory
  }

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  initialization {
    datastore_id = var.proxmox_storage

    ip_config {
      ipv4 {
        address = "${cidrhost("10.0.0.0/24", 1 + count.index)}/24" 
        gateway = "10.0.0.254"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.common_cloud_init.id
  }
}
