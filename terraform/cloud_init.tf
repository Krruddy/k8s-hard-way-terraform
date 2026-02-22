data "local_file" "admin_ssh_key" {
  filename = pathexpand(var.admin_ssh_public_key_path)
}

resource "proxmox_virtual_environment_file" "cloud_init_user" {
  content_type = "snippets"
  datastore_id = var.proxmox_snippet_storage
  node_name    = var.proxmox_name

  source_raw {
    data = templatefile("${path.module}/templates/cloud-init-user.yaml", {
      trusted_ca_key    = vault_ssh_secret_backend_ca.ssh_ca.public_key
      dev_principal  = var.ssh_principal_dev
      ansible_principal = var.ssh_principal_ansible
      admin_public_key = trimspace(data.local_file.admin_ssh_key.content)
    })

    file_name = "cloud-init-user.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_workers_meta" {
  count        = var.k8s_wkr_count
  content_type = "snippets"
  datastore_id = var.proxmox_snippet_storage
  node_name    = var.proxmox_name

  source_raw {
    data = templatefile("${path.module}/templates/cloud-init-meta.yaml", {
      local_hostname = "k8s-wkr-${count.index + 1}"
    })

    file_name = "cloud-init-k8s-wkr-${count.index + 1}-meta.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_controllers_meta" {
  count        = var.k8s_ctrl_count
  content_type = "snippets"
  datastore_id = var.proxmox_snippet_storage
  node_name    = var.proxmox_name

  source_raw {
    data = templatefile("${path.module}/templates/cloud-init-meta.yaml", {
      local_hostname = "k8s-ctrl-${count.index + 1}"
    })

    file_name = "cloud-init-k8s-ctrl-${count.index + 1}-meta.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_gateway_meta" {
  content_type = "snippets"
  datastore_id = var.proxmox_snippet_storage
  node_name    = var.proxmox_name

  source_raw {
    data = templatefile("${path.module}/templates/cloud-init-meta.yaml", {
      local_hostname = "k8s-gw"
    })

    file_name = "cloud-init-k8s-gw-meta.yaml"
  }
}
