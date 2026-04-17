resource "consul_acl_policy" "admin" {
  name        = "admin"
  datacenters = ["dc1"]
  rules       = <<-RULE
    acl = "write"
    service_prefix "" {
      policy = "write"
    }
    node_prefix "" {
      policy = "write"
    }
    key_prefix "" {
      policy = "write"
    }
    key_prefix "vault/" {
      policy = "deny"
    }
  RULE
}

resource "consul_acl_role" "admin" {
  name        = "admin"
  description = "Default role for admins"

  policies = [
    consul_acl_policy.admin.id
  ]
}

