# Enable the SSH Secrets Engine
resource "vault_mount" "ssh" {
  path = "ssh-client-signer"
  type = "ssh"
}

# Vault generates its own keypair
resource "vault_ssh_secret_backend_ca" "ssh_ca" {
  backend = vault_mount.ssh.path
  generate_signing_key = true
}

# Create the role used by the CD pipeline (Ansible) to sign its SSH keys
resource "vault_ssh_secret_backend_role" "ansible" {
  name                    = "ansible-role"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  allow_user_certificates = true
  allowed_users           = var.ssh_principal_ansible # This is a principal not a user
  default_user            = var.ssh_principal_ansible
  ttl                     = "30m"
  allowed_extensions      = "permit-pty"
  default_extensions      = { "permit-pty" : "" }
  # Set allowed_user_key_config
}

# Create the role used by the dev team members to sign their SSH keys
resource "vault_ssh_secret_backend_role" "dev_team" {
  name                    = "dev-team-role"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  allow_user_certificates = true
  allowed_users           = var.ssh_principal_dev # This is a principal not a user
  default_user            = var.ssh_principal_dev
  ttl                     = "4h"
  allowed_extensions      = "permit-pty,permit-port-forwarding"
  default_extensions      = { "permit-pty" : "" }
  # Set allowed_user_key_config
}
