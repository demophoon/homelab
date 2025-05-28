data "vault_auth_backend" "oidc" {
  path = "oidc"
}

resource "vault_jwt_auth_backend_role" "oidc-admin" {
  backend         = data.vault_auth_backend.oidc.path
  role_name       = "admin"
  token_policies  = ["admin"]

  user_claim            = "sub"
  role_type             = "oidc"
  allowed_redirect_uris = [
    "https://vault-ui.internal.demophoon.com/ui/vault/auth/oidc/oidc/callback",
    "https://vault.ts.demophoon.com/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]
}
