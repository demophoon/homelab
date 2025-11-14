resource "vault_policy" "transmission" {
  name = "transmission"
  policy = <<EOF
path "kv/data/apps/vpn" {
  capabilities = ["read"]
}
path "kv/data/apps/transmission/*" {
  capabilities = ["read"]
}
  EOF
}
