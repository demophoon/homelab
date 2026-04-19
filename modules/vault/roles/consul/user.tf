resource "vault_consul_secret_backend_role" "user" {
  name    = "user"
  backend = local.consul_backend_path

  consul_policies = [
    "user",
  ]
}
