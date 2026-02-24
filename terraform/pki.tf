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
resource "vault_pki_secret_backend_role" "kubernetes" {
  backend          = vault_mount.pki.path
  name             = "kubernetes"
  # The name of the CA managed by this role.
  issuer_ref       = vault_pki_secret_backend_root_cert.root.common_name
  ttl              = var.ca_ttl
  max_ttl          = var.ca_ttl
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.svc.cluster.local"
  ]
  allow_subdomains = true
  allow_bare_domains = true
  allow_localhost = true
  client_flag = true # Implies `ServerAuth` in the `key_usage` field
  server_flag = true # Implies `ClientAuth` in the `key_usage` field

  enforce_hostnames = false
  allow_any_name = true

  country = [
    var.organization.country
  ]
  locality = [
    var.organization.locality
  ]
  province = [
    var.organization.province
  ]
  key_usage = [
    "DigitalSignature", # The certificate can be used to sign data
    "KeyEncipherment" # Key encryption, i.e. when a symmetric key is used for data encryption and this is encrypted with the key contained in the certificate
  ]
}

