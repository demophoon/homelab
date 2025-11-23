output "backplane_certificate" {
  description = "Vault PKI Backplane Certificate"
  value       = vault_pki_secret_backend_root_cert.backplane.certificate
}
