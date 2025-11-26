resource "vault_policy" "ssh-user" {
  name = "ssh-user"
  policy = <<EOF
path "/proxmox/sign/ssh-user" {
  capabilities = ["create", "update"]
  required_parameters = ["public_key"]
}
  EOF
}
