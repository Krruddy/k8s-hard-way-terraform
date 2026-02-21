# --- Vault Variables ---

variable "vault_addr" {
  type = string
  description = "The address of the Vault server"
}

variable "vault_auth_backend_approle_path" {
  type = string
  description = "The path where the AppRole auth method is enabled in Vault."
  default = "approle"
}

variable "vault_auth_backend_approle_role_name" {
  type = string
  description = "The name of the AppRole role to authenticate with."
  default = "ansible-role"
}

variable "vault_role_id" {
  type = string
  description = "The Role ID for Vault AppRole authentication."
}

variable "vault_secret_id" {
  type = string
  description = "The Secret ID for Vault AppRole authentication."
}

# --- Proxmox Variables ---

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

variable "proxmox_snippet_storage" {
  description = "The name of the Proxmox storage pool for snippets"
  type        = string
}

variable "proxmox_pool" {
  description = "Resource Pool for the Kubernetes Cluster"
  type        = string
}

# --- General VM Variables ---

variable "template_vm_id" {
  description = "The VM ID of the Cloud-Init Template to clone"
  type        = number
}

variable "admin_ssh_public_key_path" {
  description = "Path to the public key used for the break-glass admin user"
  type = string
}

variable "ssh_principal_ansible" {
  description = "The SSH Certificate Principal used for Ansible automation identity"
  type        = string
  default     = "ansible"
}

variable "ssh_principal_dev" {
  description = "The SSH Certificate Principal used for the Developer Team identity"
  type        = string
  default     = "dev-team"
}

# --- Kubernetes Gateway Node Variables ---

variable "k8s_gateway_vm_id" {
  description = "The VM ID for the Kubernetes gateway node"
  type        = number
}

variable "k8s_gateway_wan_ip" {
  description = "The static IP address reserved for the Kubernetes gateway node on the home network"
  type        = string
  default     = "192.168.1.200/24"
}

variable "k8s_gateway_wan_mac_address" {
  description = "The MAC address for the Kubernetes gateway node's WAN interface"
  type        = string
  default     = "BC:24:11:00:00:01"
}

variable "k8s_gateway_ip" {
  description = "The static IP address for the Kubernetes gateway node"
  type        = string
  default     = "10.0.0.254/24"
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

# --- Kubernetes Controller Node Variables ---

variable "k8s_ctrl_id_start" {
  description = "Starting VM ID for controller nodes"
  type        = number
}

variable "k8s_ctrl_count" {
  description = "Number of controller nodes"
  type        = number
  default     = 3
}

variable "k8s_ctrl_cpu_cores" {
  description = "CPU cores for controller nodes"
  type        = number
  default     = 2
}

variable "k8s_ctrl_memory" {
  description = "Memory (MB) for controller nodes"
  type        = number
  default     = 4096
}

# --- Kubernetes Worker Node Variables ---

variable "k8s_wkr_id_start" {
  description = "Starting VM ID for worker nodes"
  type        = number
}

variable "k8s_wkr_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "k8s_wkr_cpu_cores" {
  description = "CPU cores for worker nodes"
  type        = number
  default     = 2
}

variable "k8s_wkr_memory" {
  description = "Memory (MB) for worker nodes"
  type        = number
  default     = 2048
}
