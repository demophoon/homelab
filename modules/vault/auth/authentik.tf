resource "vault_jwt_auth_backend_role" "authentik" {
  backend = vault_jwt_auth_backend.jwt-nomad.path
  role_name = "authentik"
  token_policies = ["authentik", "smtp-ro"]

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

resource "vault_policy" "authentik" {
  name = "authentik"
  policy = <<EOF
path "kv/data/apps/authentik/*" {
  capabilities = ["read"]
}
  EOF
}
