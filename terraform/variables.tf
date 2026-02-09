variable "vault_addr" {
  type = string
  description = "The address of the Vault server"
}

variable "vault_role_id" {
  type = string
  description = "The Role ID for Vault AppRole authentication."
}

variable "vault_secret_id" {
  type = string
  description = "The Secret ID for Vault AppRole authentication."
}

variable "proxmox_endpoint" {
  description = "The URL of the Proxmox API endpoint"
  type        = string
}
