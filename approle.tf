resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_policy" "pki_app_role" {
  name = "pki-app-role-policy"

  policy = <<EOF
path "agent-pki-trusted-ica/issue/agent-vault-trusted-ica-demo-role" {
  capabilities = ["read", "create", "update"]
}
path "agent-pki-trusted-ica/roles/agent-vault-trusted-ica-demo-role" {
  capabilities = ["read"]
}
path "auth/token/*" {
  capabilities = ["read", "create", "update"]
}
path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOF
}

resource "vault_approle_auth_backend_role" "pki_agent_app_role" {
  backend            = vault_auth_backend.approle.path
  role_name          = "pki-agent-approle"
  token_policies     = ["default", vault_policy.pki_app_role.name]
  secret_id_ttl      = 2629800
  token_num_uses     = 0
  token_ttl          = 2629800
  token_max_ttl      = 2629800 * 2
  secret_id_num_uses = 10
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.pki_agent_app_role.role_name
}
