terraform {
  required_version = ">=1.10.0" # For ephemeral resource support
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "5.7.0"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.95.0"
    }
  }
}
