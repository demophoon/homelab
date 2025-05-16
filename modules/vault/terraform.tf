resource "vault_policy" "terraform" {
  name = "terraform"
  policy = <<EOF
path "/pki/issue/backplane" {
  capabilities = ["read", "create"]
}
path "/auth/token/create" {
  capabilities = ["read", "create"]
}
path "/proxmox/config/ca" {
	capabilities = ["read"]
}
  EOF
}
