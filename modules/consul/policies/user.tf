resource "consul_acl_policy" "user" {
  name        = "user"
  datacenters = ["dc1"]
  rules       = <<-RULE
    service_prefix "" {
      policy = "read"
    }
    node_prefix "" {
      policy = "read"
    }
    key_prefix "" {
      policy = "read"
    }
    key_prefix "vault/" {
      policy = "deny"
    }
  RULE
}

resource "consul_acl_role" "read" {
  name        = "user"
  description = "Default role for users"

  policies = [
    consul_acl_policy.user.id
  ]
}
