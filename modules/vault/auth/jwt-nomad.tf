resource "vault_jwt_auth_backend" "jwt-nomad" {
  path            = "jwt-nomad"
  jwks_url        = "https://nomad.service.consul.demophoon.com:4646/.well-known/jwks.json"
  default_role    = "nomad-workloads"
  disable_remount = false
}

resource "vault_jwt_auth_backend_role" "nomad-workloads" {
  backend = vault_jwt_auth_backend.jwt-nomad.path
  role_name = "nomad-workloads"
  token_policies = ["nomad-workloads"]

  bound_audiences = ["demophoon.com"]
  user_claim = "/nomad_job_id"
  role_type = "jwt"

  claim_mappings = {
    nomad_job_id    = "nomad_job_id"
    nomad_namespace = "nomad_namespace"
    nomad_task      = "nomad_task"
  }

  disable_bound_claims_parsing = false
  token_period                 = 1800
  token_type                   = "service"
  user_claim_json_pointer      = true
}

resource "vault_policy" "nomad-workloads" {
  name = "nomad-workloads"
  policy = <<EOT
path "kv/data/{{identity.entity.aliases.AUTH_METHOD_ACCESSOR.metadata.nomad_namespace}}/{{identity.entity.aliases.AUTH_METHOD_ACCESSOR.metadata.nomad_job_id}}/*" {
  capabilities = ["read"]
}

path "kv/data/{{identity.entity.aliases.AUTH_METHOD_ACCESSOR.metadata.nomad_namespace}}/{{identity.entity.aliases.AUTH_METHOD_ACCESSOR.metadata.nomad_job_id}}" {
  capabilities = ["read"]
}

path "kv/metadata/{{identity.entity.aliases.AUTH_METHOD_ACCESSOR.metadata.nomad_namespace}}/*" {
  capabilities = ["list"]
}

path "kv/metadata/*" {
  capabilities = ["list"]
}
EOT
}
