resource "vault_policy" "nomad-cluster" {
  name = "nomad-cluster"
  policy = <<EOF
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}
path "auth/token/roles/nomad-cluster" {
  capabilities = ["read"]
}
path "auth/token/create/nomad-cluster" {
  capabilities = ["update"]
}
  EOF
}

resource "vault_policy" "nomad-server" {
  name = "nomad-server"
  policy = <<EOF
path "auth/token/create/*" {
  capabilities = ["update"]
}

path "auth/token/roles/*" {
  capabilities = ["read"]
}

# Allow looking up the token passed to Nomad to validate # the token has the
# proper capabilities. This is provided by the "default" policy.
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow looking up incoming tokens to validate they have permissions to access
# the tokens they are requesting. This is only required if
# `allow_unauthenticated` is set to false.
path "auth/token/lookup" {
  capabilities = ["update"]
}

# Allow revoking tokens that should no longer exist. This allows revoking
# tokens for dead tasks.
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}

# Allow checking the capabilities of our own token. This is used to validate the
# token upon startup.
path "sys/capabilities-self" {
  capabilities = ["update"]
}

# Allow our own token to be renewed.
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow access to the nomad-server keyring to issue workload identity tokens
path "transit/encrypt/nomad-server" {
  capabilities = ["update"]
}

path "transit/decrypt/nomad-server" {
  capabilities = ["update"]
}
  EOF
}

resource "vault_policy" "nomad-transit" {
  name = "nomad-transit"
  policy = <<EOF
# Allow access to the nomad-server keyring to issue workload identity tokens
path "transit/encrypt/nomad-server" {
  capabilities = ["update"]
}

path "transit/decrypt/nomad-server" {
  capabilities = ["update"]
}
  EOF
}

resource "vault_token_auth_backend_role" "nomad-cluster" {
  role_name              = "nomad-cluster"
  disallowed_policies    = ["nomad-server"]
  orphan                 = true
  renewable              = true
  token_period           = "2592000"
  #token_explicit_max_ttl = "7776000"
}

resource "vault_token_auth_backend_role" "traefik" {
  role_name              = "traefik"
  allowed_policies    = ["traefik"]
  renewable              = true
  token_period           = "32400"
  token_explicit_max_ttl = "2592000"
}

resource "vault_nomad_secret_backend" "cascadia" {
    backend                   = "nomad"
    description               = "cascadia nomad cluster"
    default_lease_ttl_seconds = "3600"
    max_lease_ttl_seconds     = "7200"
    max_ttl                   = "43200"
    ttl                       = "3600"
    address                   = "https://nomad.ts.demophoon.com"
}

resource "vault_nomad_secret_role" "write" {
  backend   = vault_nomad_secret_backend.cascadia.backend
  role      = "write"
  type      = "client"
  policies  = ["write"]
}

resource "vault_nomad_secret_role" "management" {
  backend   = vault_nomad_secret_backend.cascadia.backend
  role      = "management"
  type      = "management"
}
