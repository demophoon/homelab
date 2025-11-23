resource "vault_mount" "pki" {
    allowed_managed_keys         = []
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl_seconds    = 0
    external_entropy_access      = false
    local                        = false
    max_lease_ttl_seconds        = 315360000 # 10 years
    options                      = {}
    path                         = "pki"
    seal_wrap                    = false
    type                         = "pki"
}

resource "vault_pki_secret_backend_root_cert" "backplane" {
  depends_on  = [vault_mount.pki]
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Infrastructure Backplane"

  ttl                  = "315360000" # 10 years
  key_bits             = 4096
  key_type             = "rsa"
  exclude_cn_from_sans = true

  organization = "Demophoon"
  ou           = "Infrastructure"

  permitted_dns_domains = [
    "*.infrastructure.demophoon.com",
    "*.consul.demophoon.com",
    "*.consul.services.demophoon.com",
  ]
}

# Node mTLS
resource "vault_pki_secret_backend_role" "mtls" {
  backend = vault_mount.pki.path
  name = "infrastructure-mtls"
  ttl  = 2592000 # 30 days

  issuer_ref = vault_pki_secret_backend_root_cert.backplane.issuer_id

  allow_ip_sans    = true
  allowed_domains  = [
    "{{identity.entity.metadata.hostname}}.infrastructure.demophoon.com",
    "{{identity.entity.metadata.hostname}}.consul.demophoon.com",
    "{{identity.entity.metadata.hostname}}.dc1.consul.demophoon.com",
  ]
  allow_subdomains = false
}

# Server role certificates
resource "vault_pki_secret_backend_role" "server_infrastructure" {
  backend = vault_mount.pki.path
  name = "infrastructure-server"
  ttl  = 7776000 # 90 days

  issuer_ref = vault_pki_secret_backend_root_cert.backplane.issuer_id

  allow_ip_sans    = true
  allowed_domains  = [
    "vault.service.consul.demophoon.com",
    "active.vault.service.consul.demophoon.com",
    "standby.vault.service.consul.demophoon.com",
    "consul.service.consul.demophoon.com",
    "nomad.service.consul.demophoon.com",
  ]
  allow_subdomains = false
}
