# Mount the PKI secrets engine
resource "vault_mount" "pki" {
  path        = var.pki_path
  type        = "pki"
  description = "PKI secret engine used to manage certificates for the Kubernetes cluster"
  
  default_lease_ttl_seconds = var.ca_ttl
  max_lease_ttl_seconds     = var.ca_ttl
}

# Configure the CA and CRL distribution points
resource "vault_pki_secret_backend_config_urls" "config" {
  backend = vault_mount.pki.path
  issuing_certificates    = ["${var.vault_addr}/v1/${var.pki_path}/ca"]
  crl_distribution_points = ["${var.vault_addr}/v1/${var.pki_path}/crl"]
}

# Create the root CA certificate
resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on = [vault_mount.pki]
  backend = vault_mount.pki.path
  type = "internal"

  common_name = var.common_name
  ttl         = var.ca_ttl

  format                = "pem"
  private_key_format    = "der"
  key_type              = "rsa"
  key_bits              = 4096

  organization = var.organization.name
  ou = var.organization.ou
  country = var.organization.country
  locality = var.organization.locality
  province = var.organization.province
}

# Configure the rules around the certificates signed by the CA
resource "vault_pki_secret_backend_role" "k8s_roles" {

  # We loop over the 'k8s_roles_config' map to create a role for each entry.
  for_each = local.k8s_roles_config

  name = "kubernetes-${each.key}"
  organization = [
    coalesce(
      lookup(each.value, "org", null), 
      lookup(local.role_defaults, "org", null), 
      var.organization.name
    )
  ]

  allow_any_name    = lookup(each.value, "allow_any_name", local.role_defaults.allow_any_name)
  enforce_hostnames = lookup(each.value, "enforce_hostnames", local.role_defaults.enforce_hostnames)
  server_flag       = lookup(each.value, "server_flag", local.role_defaults.server_flag)
  client_flag       = lookup(each.value, "client_flag", local.role_defaults.client_flag)

  allowed_domains = lookup(each.value, "allowed_domains", local.role_defaults.allowed_domains)
  allow_subdomains   = lookup(each.value, "allow_subomains", local.role_defaults.allow_subdomains)
  

  # --- Static Values
  backend          = vault_mount.pki.path
  # The name of the CA managed by this role.
  issuer_ref       = vault_pki_secret_backend_root_cert.root.issuer_id
  ttl              = var.ca_ttl
  max_ttl          = var.ca_ttl
  allow_ip_sans    = true
  allow_localhost  = true
  key_type         = "rsa"
  key_bits         = 4096
  
  country  = [var.organization.country]
  locality = [var.organization.locality]
  province = [var.organization.province]
  
  key_usage = [
    "DigitalSignature", # The certificate can be used to sign data
    "KeyEncipherment" # Key encryption, i.e. when a symmetric key is used for data encryption and this is encrypted with the key contained in the certificate
  ]
}
