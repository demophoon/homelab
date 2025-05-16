resource "vault_jwt_auth_backend_role" "shrls" {
  backend = vault_jwt_auth_backend.jwt-nomad.path
  role_name = "shrls"
  token_policies = ["shrls"]

  bound_audiences = ["vault.io"]
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

resource "vault_policy" "shrls" {
  name = "shrls"
  policy = <<EOF
path "mongodb/creds/shrls-rw" {
  capabilities = ["read"]
}

path "kv/data/apps/shrls/app" {
  capabilities = ["read"]
}
  EOF
}
