locals {
  consul_server_tag = var.server ? "tag:consul-server" : null
  nomad_server_tag = var.server ? "tag:nomad-server" : null
  vault_server_tag = var.server ? "tag:vault-server" : null

  nomad_client_tag = !var.use_miren ? "tag:nomad-client" : null
  miren_tag = var.use_miren ? "tag:miren" : null

  ingress_tag = var.node_pool == "ingress" ? "tag:ingress" : null
}

module "ts" {
  source = "./tailscale"

  additional_tags = [
    local.consul_server_tag,
    local.nomad_server_tag,
    local.vault_server_tag,
    local.nomad_client_tag,
    local.miren_tag,
    local.ingress_tag,
  ]
}
