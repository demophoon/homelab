resource "vault_mount" "proxmox" {
    allowed_managed_keys         = []
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl_seconds    = 0
    external_entropy_access      = false
    local                        = false
    max_lease_ttl_seconds        = 0
    options                      = {}
    path                         = "proxmox"
    seal_wrap                    = false
    type                         = "ssh"
}

resource "vault_ssh_secret_backend_ca" "proxmox_ca" {
    backend              = vault_mount.proxmox.path
    key_type             = "ssh-rsa"
    generate_signing_key = true
}

resource "vault_ssh_secret_backend_role" "admin" {
    name                    = "admin"
    backend                 = vault_mount.proxmox.path
    key_type                = "ca"
    allow_user_certificates = true
    allow_host_certificates = false

    allowed_domains          = "*"
    allowed_extensions       = "permit-pty,permit-port-forwarding"
    allowed_users            = "britt"

    default_extensions       = {
        permit-pty = ""
    }
    default_user             = "britt"
}

resource "vault_ssh_secret_backend_role" "ssh-user" {
    name                    = "ssh-user"
    backend                 = vault_mount.proxmox.path
    key_type                = "ca"
    allow_user_certificates = true
    allow_host_certificates = false

    ttl                     = "1800"
    max_ttl                 = "86400"

    allowed_domains          = "*"
    allowed_extensions       = "permit-pty,permit-port-forwarding"

    default_extensions       = {
        permit-pty = ""
    }

    default_user_template  = true
    default_user           = "{{ identity.entity.aliases.auth_oidc_5c9f32f5.metadata.ssh_username }}"
    allowed_users_template = true
    allowed_users          = "{{ identity.entity.aliases.auth_oidc_5c9f32f5.metadata.ssh_username }}"
}
