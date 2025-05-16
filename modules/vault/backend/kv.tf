resource "vault_mount" "kv" {
  default_lease_ttl_seconds    = 0
  max_lease_ttl_seconds        = 0
  options                      = {
    "version" = "2"
  }
  path                         = "kv"
  seal_wrap                    = false
  type                         = "kv"
}

