resource "vault_mount" "gcp" {
    allowed_managed_keys         = []
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl_seconds    = 0
    external_entropy_access      = false
    local                        = false
    max_lease_ttl_seconds        = 0
    options                      = {}
    path                         = "gcp"
    seal_wrap                    = false
    type                         = "gcp"
}

