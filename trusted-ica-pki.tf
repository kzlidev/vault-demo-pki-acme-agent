locals {
  trusted_uca_csr_request_path = "${path.module}/tmp/trusted-ica.csr"
  mount_point_name             = "pki-trusted-ica"
}

# 1. Create mounted ICA Path
resource "vault_mount" "trusted_ica" {
  path                      = local.mount_point_name
  type                      = "pki"
  description               = "Trusted ICA PKI"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = 8640000
  allowed_response_headers  = [
    "Last-Modified",
    "Location",
    "Replay-Nonce",
    "Link"
  ]
  passthrough_request_headers = [
    "If-Modified-Since"
  ]
}

# 2. Configure ICA cluster
resource "vault_pki_secret_backend_config_cluster" "example" {
  backend  = vault_mount.trusted_ica.path
  path     = "${var.vault_addr}/v1/${local.mount_point_name}"
  aia_path = "${var.vault_addr}/v1/${local.mount_point_name}"
}

resource "vault_pki_secret_backend_config_acme" "acme" {
  backend                  = vault_mount.trusted_ica.path
  enabled                  = true
  allowed_issuers          = ["*"]
  allowed_roles            = ["*"]
  allow_role_ext_key_usage = false
  default_directory_policy = "sign-verbatim"
  dns_resolver             = ""
  eab_policy               = "always-required"
}

resource "vault_pki_secret_backend_config_urls" "example" {
  backend              = vault_mount.trusted_ica.path
  issuing_certificates = [
    "${var.vault_addr}/v1/${local.mount_point_name}/ca",
  ]
}

# 3. Generate CSR, which is signed in `root-pki-offline.tf`
resource "vault_pki_secret_backend_intermediate_cert_request" "csr_request" {
  backend     = vault_mount.trusted_ica.path
  common_name = "Demo Vault Trusted ICA Intermediate Authority"
  # If type = internal, a new private key will always be created
  type        = "internal"
  uri_sans    = ["localhost", "example.com"]
  # If type = existing, you can reference an existing private key to create the CSR
  #  type        = "existing"
  #  key_ref     = "32523adb-e37b-aa35-8c8f-3fa2c6a0d1e2"
}

# 3b. Save CSR as physical file (optional)
resource "local_file" "trusted_ica_csr_request" {
  content  = vault_pki_secret_backend_intermediate_cert_request.csr_request.csr
  filename = local.trusted_uca_csr_request_path
}

# 4. Import back signed cert into PKI secrets engine
resource "vault_pki_secret_backend_intermediate_set_signed" "trusted_ica" {
  backend     = vault_mount.trusted_ica.path
  certificate = tls_locally_signed_cert.cluster_trusted_ica_signed_cert.cert_pem
}

# 5. Configure issuer
resource "vault_pki_secret_backend_config_issuers" "config" {
  backend                       = vault_mount.trusted_ica.path
  default                       = element(vault_pki_secret_backend_intermediate_set_signed.trusted_ica.imported_issuers, -1)
  default_follows_latest_issuer = true
}

# 6. Configure PKI role
resource "vault_pki_secret_backend_role" "trusted_ica_role" {
  backend          = vault_mount.trusted_ica.path
  name             = "vault-trusted-ica-demo-role"
  ttl              = 86400
  allow_ip_sans    = true
  allowed_domains  = ["localhost", "example.com"]
  allow_subdomains = true
  key_type         = "any"
}

output "issuers" {
  value = vault_pki_secret_backend_intermediate_set_signed.trusted_ica.imported_issuers
}

# Configure ACME EAB
resource "vault_pki_secret_backend_acme_eab" "test" {
  backend = vault_mount.trusted_ica.path
  role    = vault_pki_secret_backend_role.trusted_ica_role.name
}
