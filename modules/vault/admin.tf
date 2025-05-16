resource "vault_policy" "admin" {
  name = "admin"
  policy = <<EOF

path "/*" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}

path "/ssh/*" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}

path "/auth/userpass/*" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}
path "/auth/token/*" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}

path "/sys" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}

path "/sys/*" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}

path "/sys/leases" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}

path "/sys/leases/*" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}

path "kv/*" {
  capabilities = ["sudo", "read", "create", "update", "patch", "list", "delete"]
}

path "/gcp/roleset/*" {
    capabilities = ["read"]
}

  EOF
}
