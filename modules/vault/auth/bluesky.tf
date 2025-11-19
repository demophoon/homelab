resource "vault_jwt_auth_backend_role" "bluesky" {
  backend = vault_jwt_auth_backend.jwt-nomad.path
  role_name = "bluesky"
  token_policies = ["bluesky"]

  bound_audiences = local.default_aud
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

resource "vault_policy" "bluesky" {
  name = "bluesky"
  policy = <<EOF
path "kv/data/apps/bluesky" {
  capabilities = ["read"]
}
path "kv/data/apps/smtp" {
  capabilities = ["read"]
}
  EOF
}
