resource "consul_acl_policy" "vault_node" {
  name        = "vault_node"
  datacenters = ["dc1"]
  rules       = <<-RULE
    service_prefix "vault" {
      policy = "write"
    }
    key_prefix "vault/" {
      policy = "write"
    }
  RULE
}

resource "consul_acl_role" "vault_node" {
  name        = "vault_node"
  description = "Role for vault nodes to access Consul"

  policies = [
    consul_acl_policy.vault_node.id
  ]
}

