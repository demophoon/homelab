resource "vault_consul_secret_backend_role" "admin" {
  name    = "admin"
  backend = "consul"

  consul_policies = [
    "admin",
  ]
}
