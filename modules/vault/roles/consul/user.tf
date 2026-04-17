resource "vault_consul_secret_backend_role" "user" {
  name    = "user"
  backend = "consul"

  consul_policies = [
    "user",
  ]
}
