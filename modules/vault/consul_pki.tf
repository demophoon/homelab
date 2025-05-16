resource "vault_policy" "consul-pki" {
  name = "consul-pki"
  policy = <<EOF
path "pki/issue/backplane/+" {
  capabilities = ["read", "update", "create", "delete"]
}

path "pki/issue/backplane" {
  capabilities = ["read", "update", "create", "delete"]
}
  EOF
}
