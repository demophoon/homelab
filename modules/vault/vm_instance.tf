resource "vault_auth_backend" "approle" {
    path     = "approle"
    type     = "approle"
}

resource "vault_policy" "vm_instance" {
  name = "vm_instance"

  policy = <<EOT
path "auth/token/create" {
  #capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
  capabilities = ["create", "update"]
}
path "proxmox/sign/host" {
  capabilities = ["create", "update"]
}
path "pki/issue/backplane" {
  capabilities = ["create", "update"]
  allowed_parameters = {
    "common_name" = []
    "alt_names" = [
      "consul.service.consul.demophoon.com",
      "nomad.service.consul.demophoon.com",
      "vault.service.consul.demophoon.com,active.vault.service.consul.demophoon.com,standby.vault.service.consul.demophoon.com",
    ]
  }
}
path "kv/data/infra/{{ identity.entity.aliases.auth_approle_e5f1224d.metadata.hostname }}/nomad_server" {
  capabilities = ["read"]
}
EOT
}

resource "vault_approle_auth_backend_role" "vm_instance" {
  backend        = vault_auth_backend.approle.id
  role_name      = "vm_instance"
  token_policies = [
    vault_policy.vm_instance.name,
    vault_policy.nomad-server.name,
  ]
  secret_id_num_uses = 1
  secret_id_ttl = "300"
}
