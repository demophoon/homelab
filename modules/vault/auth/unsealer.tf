resource "vault_jwt_auth_backend_role" "unsealer" {
  backend = vault_jwt_auth_backend.jwt-nomad.path
  role_name = "unsealer"
  token_policies = ["unsealer"]

  bound_audiences = local.infrastructure_aud
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

resource "vault_policy" "unsealer" {
  name = "unsealer"
  policy = <<EOF
path "kv/data/env/infra/vault" {
  capabilities = ["read"]
}
path "transit/decrypt/auto-unseal" {
  capabilities = ["create", "update"]
}
  EOF
}
