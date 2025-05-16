resource "vault_jwt_auth_backend_role" "registry-cache" {
  backend = vault_jwt_auth_backend.jwt-nomad.path
  role_name = "registry-cache"
  token_policies = ["registry-cache"]

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

resource "vault_policy" "registry-cache" {
  name = "registry-cache"
  policy = <<EOF
path "kv/data/apps/dockerhub" {
  capabilities = ["read"]
}

path "pki/issue/backplane" {
  capabilities = ["create", "update"]
  allowed_parameters = {
    "common_name" = [
      "registry-cache.service.consul.demophoon.com",
    ]
  }
}
  EOF
}
