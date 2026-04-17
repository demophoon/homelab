resource "vault_consul_secret_backend_role" "vault_node" {
  name    = "vault_node"
  backend = "consul"

  consul_policies = [
    "vault_node",
  ]
}

