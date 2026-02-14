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
  type = string
}

variable "proxmox_name" {
  description = "The name of the Proxmox instance"
  type        = string
}

variable "proxmox_storage" {
  description = "The name of the Proxmox storage pool"
  type        = string
}

variable "template_vm_id" {
  description = "The VM ID of the Cloud-Init Template to clone (e.g., 9000)"
  type        = number
}

variable "k8s_gateway_cpu_cores" { 
  description = "Number of CPU cores for the Kubernetes gateway node" 
  type = number 
  default = 2
}
variable "k8s_gateway_memory" {
  description = "Amount of memory (in MB) for the Kubernetes gateway node"
  type = number
  default = 4096
}
variable "k8s_gateway_vm_id" {
  description = "The VM ID for the Kubernetes gateway node"
  type        = number
}

variable "ssh_public_key" { 
  description = "The SSH public key to be added to the VMs for access"
  type = string
}
