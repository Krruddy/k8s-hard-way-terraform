data "local_file" "admin_ssh_key" {
  filename = pathexpand(var.admin_ssh_public_key_path)
}

resource "proxmox_virtual_environment_file" "common_cloud_init" {
  content_type = "snippets"
  datastore_id = var.proxmox_snippet_storage
  node_name    = var.proxmox_name

  source_raw {
    data = templatefile("${path.module}/templates/common-auth.yaml", {
      trusted_ca_key    = vault_ssh_secret_backend_ca.ssh_ca.public_key
      dev_principal  = var.ssh_principal_dev
      ansible_principal = var.ssh_principal_ansible
      admin_public_key = trimspace(data.local_file.admin_ssh_key.content)
    })

    file_name = "common-auth-v1.yaml"
  }
}
