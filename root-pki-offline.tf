# Sign Server Certificate by Private CA
resource "tls_locally_signed_cert" "cluster_trusted_ica_signed_cert" {
  // CSR by the cluster servers
  cert_request_pem   = vault_pki_secret_backend_intermediate_cert_request.csr_request.csr
  // CA Private key
  ca_private_key_pem = file(var.ca_private_key_abs_path)
  // CA certificate
  ca_cert_pem        = file(var.ca_cert_abs_path)
  is_ca_certificate  = true

  validity_period_hours = 720

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
    "cert_signing",
    "crl_signing"
  ]
}

resource "tls_locally_signed_cert" "agent_cluster_trusted_ica_signed_cert" {
  // CSR by the cluster servers
  cert_request_pem   = vault_pki_secret_backend_intermediate_cert_request.agent_csr_request.csr
  // CA Private key
  ca_private_key_pem = file(var.ca_private_key_abs_path)
  // CA certificate
  ca_cert_pem        = file(var.ca_cert_abs_path)
  is_ca_certificate  = true

  validity_period_hours = 720

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
    "cert_signing",
    "crl_signing"
  ]
}


resource "local_file" "signed_trusted_ica_cert" {
  content  = tls_locally_signed_cert.cluster_trusted_ica_signed_cert.cert_pem
  filename = "${path.module}/tmp/signed-trusted-ica.pem"
}