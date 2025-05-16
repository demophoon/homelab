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
