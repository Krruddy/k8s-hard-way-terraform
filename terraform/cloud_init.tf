resource "proxmox_virtual_environment_file" "common_cloud_init" {
  content_type = "snippets"
  datastore_id = var.proxmox_snippet_storage
  node_name    = var.proxmox_name

  source_raw {
    data = templatefile("${path.module}/templates/common-auth.yaml", {
      trusted_ca_key    = vault_ssh_secret_backend_ca.ssh_ca.public_key
      dev_principal  = "dev-team"
      ansible_principal = "ansible"
    })

    file_name = "common-auth-v1.yaml"
  }
}