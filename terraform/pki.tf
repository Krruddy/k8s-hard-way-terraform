# Mount the PKI secrets engine for the main Kubernetes CA
resource "vault_mount" "kubernetes_pki" {
  path        = var.pki_path_kubernetes
  type        = "pki"
  description = "PKI secret engine used to manage certificates for the Kubernetes cluster"
  
  default_lease_ttl_seconds = var.ca_ttl
  max_lease_ttl_seconds     = var.ca_ttl
}

# Mount the PKI secrets engine for the aggregation layer CA
resource "vault_mount" "aggregation_layer_pki" {
  path        = var.pki_path_aggregation_layer
  type        = "pki"
  description = "PKI secret engine used to manage certificates for the aggregation layer"
  
  default_lease_ttl_seconds = var.ca_ttl
  max_lease_ttl_seconds     = var.ca_ttl
}

# Configure the CA and CRL distribution points for main Kubernetes CA
resource "vault_pki_secret_backend_config_urls" "kubernetes_config" {
  backend = vault_mount.kubernetes_pki.path
  issuing_certificates    = ["${var.vault_addr}/v1/${var.pki_path_kubernetes}/ca"]
  crl_distribution_points = ["${var.vault_addr}/v1/${var.pki_path_kubernetes}/crl"]
}

# Configure the CA and CRL distribution points for the aggregation layer CA
resource "vault_pki_secret_backend_config_urls" "aggregation_layer_config" {
  backend = vault_mount.aggregation_layer_pki.path
  issuing_certificates    = ["${var.vault_addr}/v1/${var.pki_path_aggregation_layer}/ca"]
  crl_distribution_points = ["${var.vault_addr}/v1/${var.pki_path_aggregation_layer}/crl"]
}

# Create the root CA certificate for Kubernetes
resource "vault_pki_secret_backend_root_cert" "root_kubernetes" {
  depends_on = [vault_mount.kubernetes_pki]
  backend = vault_mount.kubernetes_pki.path
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

# Create the root CA certificate for the aggregation layer
resource "vault_pki_secret_backend_root_cert" "root_aggregation_layer" {
  depends_on = [vault_mount.aggregation_layer_pki]
  backend = vault_mount.aggregation_layer_pki.path
  type = "internal"

  common_name = var.common_name_aggregation_layer
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
  allow_subdomains   = lookup(each.value, "allow_subdomains", local.role_defaults.allow_subdomains)
  allow_bare_domains = lookup(each.value, "allow_bare_domains", local.role_defaults.allow_bare_domains)
  

  # --- Static Values
  backend          = vault_mount.kubernetes_pki.path
  # The name of the CA managed by this role.
  issuer_ref       = vault_pki_secret_backend_root_cert.root_kubernetes.issuer_id
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

# Configure the rules around the certificates signed by the CA for the aggregation layer
resource "vault_pki_secret_backend_role" "k8s_role_aggregation_layer" {

  name = "kubernetes-aggregation-layer"
  organization = ["aggregation-layer"]

  allow_any_name    = false
  enforce_hostnames = false
  server_flag       = false
  client_flag       = true

  allowed_domains    = [
    "kubernetes-aggregation-layer",
    "front-proxy",
  ]
  allow_subdomains   = false
  allow_bare_domains = true
  
  backend          = vault_mount.aggregation_layer_pki.path
  issuer_ref       = vault_pki_secret_backend_root_cert.root_aggregation_layer.issuer_id
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
