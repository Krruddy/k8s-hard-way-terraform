resource "proxmox_virtual_environment_vm" "workers" {
  count     = var.k8s_wkr_count
  name      = "k8s-wkr-${count.index + 1}"
  node_name = var.proxmox_name
  vm_id     = var.k8s_wkr_id_start + count.index + 1
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
    cores = var.k8s_wkr_cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.k8s_wkr_memory
  }

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  initialization {
    datastore_id = var.proxmox_storage

    ip_config {
      ipv4 { 
        address = "${cidrhost("10.0.0.0/24", 21 + count.index)}/24" 
        gateway = "10.0.0.254"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_user.id
    meta_data_file_id = proxmox_virtual_environment_file.cloud_init_workers_meta[count.index].id
  }
}
