resource "consul_acl_policy" "nomad_node" {
  name        = "nomad_node"
  datacenters = ["dc1"]
  rules       = <<-RULE
  agent_prefix "" {
    policy = "read"
  }

  node_prefix "" {
    policy = "write"
  }

  service_prefix "" {
    policy = "write"
  }

  acl  = "write"
  mesh = "write"
  RULE
}

resource "consul_acl_role" "nomad_node" {
  name        = "nomad_node"
  description = "Role for nomad nodes to access Consul"

  policies = [
    consul_acl_policy.nomad_node.id
  ]
}
