resource "vault_policy" "authelia" {
  name = "authelia"
  policy = <<EOF
path "kv/data/authelia/secrets" {
  capabilities = ["read"]
}
  EOF
}
