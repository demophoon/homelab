resource "consul_acl_policy" "consul_server_node" {
  name        = "consul_server_node"
  datacenters = ["dc1"]
  rules       = <<-RULE
  agent_prefix "" {
    policy = "write"
  }

  acl  = "write"
  mesh = "write"
  RULE
}

resource "consul_acl_policy" "consul_agent_node" {
  name        = "consul_agent_node"
  datacenters = ["dc1"]
  rules       = <<-RULE
  node_prefix "" {
    policy = "write"
  }

  service_prefix "" {
    policy = "write"
  }
  RULE
}

resource "consul_acl_role" "consul_server_node" {
  name        = "consul_server_node"
  description = "Role for consul servers to access Consul"

  policies = [
    consul_acl_policy.consul_agent_node.id,
    consul_acl_policy.consul_server_node.id,
  ]
}

resource "consul_acl_role" "consul_agent_node" {
  name        = "consul_agent_node"
  description = "Role for consul agents to access Consul"

  policies = [
    consul_acl_policy.consul_agent_node.id,
  ]
}
