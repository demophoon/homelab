resource "vault_policy" "host-key-signer" {
  name = "host-key-signer"
  policy = <<EOF
path "/proxmox/sign/host" {
  capabilities = ["read", "create", "update"]
}
  EOF
}
