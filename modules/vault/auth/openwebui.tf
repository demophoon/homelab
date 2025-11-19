resource "vault_jwt_auth_backend_role" "openwebui" {
  backend = vault_jwt_auth_backend.jwt-nomad.path
  role_name = "openwebui"
  token_policies = ["openwebui"]

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

resource "vault_policy" "openwebui" {
  name = "openwebui"
  policy = <<EOF
path "kv/data/apps/openwebui/*" {
  capabilities = ["read"]
}
  EOF
}
