resource "vault_mount" "postgres" {
    allowed_managed_keys         = []
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl_seconds    = 1800
    external_entropy_access      = false
    local                        = false
    max_lease_ttl_seconds        = 86400
    options                      = {}
    path                         = "postgres"
    seal_wrap                    = false
    type                         = "database"
}

ephemeral "vault_kv_secret_v2" "postgres-nas" {
  mount = vault_mount.kv.path
  mount_id = vault_mount.kv.id
  name = "apps/postgres-nas"
}

resource "vault_database_secret_backend_connection" "postgres-nas" {
  allowed_roles            = [
      "nextcloud-rw",
      "nextcloud-admin",
  ]
  backend       = vault_mount.postgres.path
  name                     = "cube"
  plugin_name              = "postgresql-database-plugin"
  verify_connection        = false

  postgresql {
    connection_url          = "postgresql://{{username}}:{{password}}@postgres-nas.service.consul.demophoon.com:5432/postgres"
    max_connection_lifetime = 0
    max_idle_connections    = 0
    max_open_connections    = 10
    password_authentication = "password"
    self_managed            = false
    username                = "capped3577"
    password_wo             = ephemeral.vault_kv_secret_v2.postgres-nas.data.password
    password_wo_version     = 0
  }
}
