locals {
  agent_pki_mount_point_name         = "agent-pki-trusted-ica"
  agent_trusted_uca_csr_request_path = "${path.module}/tmp/agent-trusted-ica.csr"
}

# 1. Create mounted ICA Path
resource "vault_mount" "agent_trusted_ica" {
  path                      = local.agent_pki_mount_point_name
  type                      = "pki"
  description               = "Agent Trusted ICA PKI"
  default_lease_ttl_seconds = 8640000
  max_lease_ttl_seconds     = 8640000
}

# 2. Configure ICA cluster
resource "vault_pki_secret_backend_config_cluster" "agent_cluster_config" {
  backend  = vault_mount.agent_trusted_ica.path
  path     = "${var.vault_addr}/v1/${local.agent_pki_mount_point_name}"
  aia_path = "${var.vault_addr}/v1/${local.agent_pki_mount_point_name}"
}

resource "vault_pki_secret_backend_config_urls" "agent_config_url" {
  backend              = vault_mount.agent_trusted_ica.path
  issuing_certificates = [
    "${var.vault_addr}/v1/${local.agent_pki_mount_point_name}/ca",
  ]
}

# 3. Generate CSR, which is signed in `root-pki-offline.tf`
resource "vault_pki_secret_backend_intermediate_cert_request" "agent_csr_request" {
  backend     = vault_mount.agent_trusted_ica.path
  common_name = "Demo Vault Agent Trusted ICA Intermediate Authority"
  # If type = internal, a new private key will always be created
  type        = "internal"
  uri_sans    = ["localhost", "example.com"]
  # If type = existing, you can reference an existing private key to create the CSR
  #  type        = "existing"
  #  key_ref     = "32523adb-e37b-aa35-8c8f-3fa2c6a0d1e2"
}

# 3b. Save CSR as physical file (optional)
resource "local_file" "agent_trusted_ica_csr_request" {
  content  = vault_pki_secret_backend_intermediate_cert_request.agent_csr_request.csr
  filename = local.agent_trusted_uca_csr_request_path
}

# 4. Import back signed cert into PKI secrets engine
resource "vault_pki_secret_backend_intermediate_set_signed" "agent_trusted_ica" {
  backend     = vault_mount.agent_trusted_ica.path
  certificate = tls_locally_signed_cert.agent_cluster_trusted_ica_signed_cert.cert_pem
}

# 5. Configure issuer
resource "vault_pki_secret_backend_config_issuers" "agent_config" {
  backend                       = vault_mount.agent_trusted_ica.path
  default                       = element(vault_pki_secret_backend_intermediate_set_signed.agent_trusted_ica.imported_issuers, -1)
  default_follows_latest_issuer = true
}

# 6. Configure PKI role
resource "vault_pki_secret_backend_role" "agent_trusted_ica_role" {
  backend          = vault_mount.agent_trusted_ica.path
  name             = "agent-vault-trusted-ica-demo-role"
  ttl              = 86400
  allow_ip_sans    = true
  allowed_domains  = ["localhost", "example.com"]
  allow_subdomains = true
  key_type         = "rsa"
  key_bits         = 2048
}
