job "postgres" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  group "database" {
    network {
      port "db" { static = 5432 }
    }

    task "postgres" {
      driver = "docker"

      template {
        data = <<-EOT
          {{ with secret "kv/data/apps/postgres-nas" }}
          POSTGRES_USER="{{ .Data.data.username }}"
          POSTGRES_PASSWORD="{{ .Data.data.password }}"
          POSTGRES_DB="{{ .Data.data.database }}"
          {{ end }}
        EOT
        destination = "local/config"
        env = true
        # TODO: Activate in Nomad 1.10.0+
        #once = true
      }

      config {
        image = "postgres:16-alpine"
        ports = ["db"]
        volumes = [
          "/mnt/dank0/andromeda/nas-postgres:/var/lib/postgresql/data",
        ]
      }

      resources {
        cpu    = 1000
        memory = 512
      }

      vault {
        role = "postgres-nas"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
