resource "vault_consul_secret_backend_role" "consul_server_node" {
  name    = "consul_server_node"
  backend = local.consul_backend_path

  consul_policies = [
    "consul_server_node",
  ]
}

resource "vault_consul_secret_backend_role" "consul_agent_node" {
  name    = "consul_agent_node"
  backend = local.consul_backend_path

  consul_policies = [
    "consul_agent_node",
  ]
}
