provider "vault" {
  address = var.vault_addr
  auth_login {
    path = "auth/approle/login"
    parameters = {
       role_id = var.vault_role_id
       secret_id = var.vault_secret_id
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = ephemeral.vault_kv_secret_v2.proxmox_creds.data["terraform_api_token"]
  insecure  = true
}
