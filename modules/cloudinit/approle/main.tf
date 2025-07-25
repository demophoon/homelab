data "vault_approle_auth_backend_role_id" "provision_role" {
  backend   = "approle"
  role_name = "vm_instance"
}

resource "vault_approle_auth_backend_role_secret_id" "provision_secret" {
  backend   = "approle"
  role_name = "vm_instance"
  cidr_list = ["100.64.0.0/10"]
  metadata  = jsonencode({
    hostname = var.hostname
  })
}
