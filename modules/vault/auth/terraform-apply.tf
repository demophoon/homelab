resource "vault_jwt_auth_backend_role" "terraform-apply" {
  backend = vault_jwt_auth_backend.jwt-nomad.path
  role_name = "terraform-apply"
  token_policies = ["terraform-apply"]

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

resource "vault_policy" "terraform-apply" {
  name = "terraform-apply"
  policy = <<-EOF
    # Setting required environment variables for providers
    path "kv/data/env/infra/terraform" {
      capabilities = ["read"]
    }
    path "kv/data/env/infra/tfc" {
      capabilities = ["read"]
    }

    # Creating vault policies
    path "auth/token/create" {
      capabilities = ["create", "update"]
    }
    path "auth/token/lookup-self" {
      capabilities = ["read"]
    }
    path "sys/policies/acl/+" {
      capabilities = ["read", "list", "create", "update"]
    }

    # Manage secret engines
    path "sys/mounts/+" {
      capabilities = ["read", "list", "create", "update"]
    }

    # Manage auth backends
    path "sys/mounts/auth/+" {
      capabilities = ["read", "list", "create", "update"]
    }
    path "sys/mounts/auth/+/*" {
      capabilities = ["read", "list", "create", "update"]
    }
    path "auth/+/role/+" {
      capabilities = ["read", "list", "create", "update"]
    }
    path "auth/+/roles/+" {
      capabilities = ["read", "list", "create", "update"]
    }
    path "auth/approle/role/vm_instance/role-id" {
      capabilities = ["read", "list", "create", "update"]
    }
    path "auth/jwt-nomad/config" {
      capabilities = ["read", "list", "create", "update"]
    }

    # Manage Nomad auth backend
    path "nomad/config/access" {
      capabilities = ["read", "list", "create", "update"]
    }
    path "nomad/config/lease" {
      capabilities = ["read", "list", "create", "update"]
    }
    path "nomad/role/+" {
      capabilities = ["read", "list", "create", "update"]
    }

    # Manage google dns
    path "gcp/roleset/dns-admin/key" {
      capabilities = ["read", "create"]
    }

    # Read CA certificates for infrastructure services
    path "pki/cert/ca_chain" {
      capabilities = ["read"]
    }

    # Stow/Manage secrets for new VM instances
    path "kv/metadata/infra/+/nomad_server" {
      capabilities = ["read", "list", "create", "update", "delete"]
    }
    path "kv/data/infra/+/nomad_server" {
      capabilities = ["read", "list", "create", "update", "delete"]
    }

    # Provision approle for VM instances
    path "auth/approle/role/vm_instance/secret-id-accessor/lookup" {
      capabilities = ["read", "list", "create", "update", "delete"]
    }
    path "auth/approle/role/vm_instance/secret-id-accessor/destroy" {
      capabilities = ["read", "list", "create", "update", "delete"]
    }
    path "auth/approle/role/vm_instance/secret-id" {
      capabilities = ["read", "list", "create", "update", "delete"]
    }

    # Create certificates for VM instances
    path "pki/issue/backplane" {
      capabilities = ["create", "update", "delete"]
    }

    # Create Nomad Tokens
    path "auth/token/create" {
      capabilities = ["read", "create", "update", "delete", "sudo"]
    }
  EOF
}
