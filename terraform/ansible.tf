# Create the Policy
resource "vault_policy" "ansible" {
  name = "ansible-policy"

  policy = <<EOT
# Permit creating a new token that is a child of the one given
path "auth/token/create"
{
  capabilities = ["update"]
}
# Allow signing keys using the 'ansible-role'
path "ssh-client-signer/sign/ansible-signer" {
  capabilities = ["update", "read"]
}
EOT
}

# Create the Ansible AppRole Role
resource "vault_approle_auth_backend_role" "ansible" {
  backend        = var.vault_auth_backend_approle_path
  role_name      = var.vault_auth_backend_approle_role_name
  token_policies = [vault_policy.ansible.name]
  token_ttl      = "3600"   # Token lives for 1 hour
  token_max_ttl  = "14400"  # Token can be renewed up to 4 hours
}
