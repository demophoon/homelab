ephemeral "vault_kv_secret_v2" "consul_token" {
  mount = vault_mount.kv.path
  mount_id = vault_mount.kv.id
  name = "env/infra/consul"
}

#resource "vault_consul_secret_backend" "consul" {
#  path        = "consul"
#  description = "cascadia consul cluster"
#  scheme      = "https"
#  address     = "consul.service.consul.demophoon.com:8501"
#  token_wo    = tostring(ephemeral.vault_kv_secret_v2.consul_token.data.token)
#}
