resource "vault_policy" "smtp-ro" {
  name = "smtp-ro"
  policy = <<EOF
path "kv/data/apps/smtp" {
  capabilities = ["read"]
}
  EOF
}
