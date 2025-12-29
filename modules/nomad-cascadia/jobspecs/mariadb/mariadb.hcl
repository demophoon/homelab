job "mariadb" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  group "database" {
    network {
      port "db" { to = 3306 }
    }

    task "mariadb" {
      driver = "docker"

      template {
        data = <<-EOT
          {{ with secret "kv/data/apps/mariadb-nas" }}
          MYSQL_USER="{{ .Data.data.username }}"
          MYSQL_PASSWORD="{{ .Data.data.password }}"
          MYSQL_DATABASE="{{ .Data.data.database }}"

          MYSQL_ROOT_PASSWORD="{{ .Data.data.root_password }}"
          {{ end }}
        EOT
        destination = "secrets/config"
        env = true
        # TODO: Activate in Nomad 1.10.0+
        #once = true
      }

      config {
        image = "mariadb:11.4"
        ports = ["db"]
        volumes = [
          "/mnt/dank0/andromeda/nas-mariadb/data:/var/lib/mysql",
          "/mnt/dank0/andromeda/nas-mariadb/config:/config",
        ]
      }

      resources {
        cpu    = 1000
        memory = 512
      }

      service {
        name = "mariadb-nas"
        port = "db"
      }

      vault {
        role = "mariadb-nas"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
