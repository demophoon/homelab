locals {
  claim_mappings = {
    "ssh_username" = "ssh_username"
  }
}

data "vault_auth_backend" "oidc" {
  path = "oidc"
}

resource "vault_identity_group" "ssh-user" {
  name     = "SSH Users"
  type     = "external"
  policies = ["ssh-user"]
}

resource "vault_identity_group" "admin-user" {
  name     = "Admin Users"
  type     = "external"
  policies = ["admin"]
}

resource "vault_identity_group_alias" "ssh-user-alias" {
  name           = "Authentik SSH Users"
  mount_accessor = data.vault_auth_backend.oidc.accessor
  canonical_id   = vault_identity_group.ssh-user.id
}

resource "vault_identity_group_alias" "admin-user-alias" {
  name           = "Authentik Admin Users"
  mount_accessor = data.vault_auth_backend.oidc.accessor
  canonical_id   = vault_identity_group.admin-user.id
}

resource "vault_jwt_auth_backend_role" "oidc-ssh-user" {
  backend         = data.vault_auth_backend.oidc.path
  role_name       = "ssh-user"
  token_policies  = ["ssh-user"]

  claim_mappings = local.claim_mappings

  oidc_scopes           = ["openid", "profile", "email"]
  user_claim            = "email"
  groups_claim          = "vault_groups"
  role_type             = "oidc"
  allowed_redirect_uris = [
    "https://vault-ui.internal.demophoon.com/ui/vault/auth/oidc/oidc/callback",
    "https://vault.ts.demophoon.com/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]
}

resource "vault_jwt_auth_backend_role" "oidc-admin" {
  backend         = data.vault_auth_backend.oidc.path
  role_name       = "admin"
  token_policies  = ["admin"]

  claim_mappings = local.claim_mappings

  oidc_scopes           = ["openid", "profile", "email"]
  user_claim            = "email"
  groups_claim          = "vault_groups"
  role_type             = "oidc"
  allowed_redirect_uris = [
    "https://vault-ui.internal.demophoon.com/ui/vault/auth/oidc/oidc/callback",
    "https://vault.ts.demophoon.com/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]
}
