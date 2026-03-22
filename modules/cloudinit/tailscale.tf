locals {
  consul_server_tag = var.server ? "tag:consul_server" : null
  nomad_server_tag = var.server ? "tag:nomad_server" : null
  vault_server_tag = var.server ? "tag:vault_server" : null

  nomad_client_tag = !var.use_miren ? "tag:nomad_client" : null
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
