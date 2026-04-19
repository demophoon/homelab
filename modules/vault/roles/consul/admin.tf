resource "vault_consul_secret_backend_role" "admin" {
  name    = "admin"
  backend = local.consul_backend_path

  consul_policies = [
    "admin",
  ]
}
