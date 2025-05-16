output "provision_role_id" {
  value = data.vault_approle_auth_backend_role_id.provision_role.role_id
}

output "secret_id" {
  value = vault_approle_auth_backend_role_secret_id.provision_secret.secret_id
}
