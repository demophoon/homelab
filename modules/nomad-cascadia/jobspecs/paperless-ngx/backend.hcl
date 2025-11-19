job "paperless-backend" {
  datacenters = ["cascadia"]

  affinity {
    attribute = "${unique.consul.name}"
    operator  = "regexp"
    value     = "^proxmox-.*"
    weight    = 100
  }

  group "postgres" {
    count = 1
    network {
      port "db" { to = 5432 }
    }

    task "db" {
      driver = "docker"
      config {
        image = "postgres:16"
        ports = ["db"]
        volumes = [
          "/mnt/nfs/paperless-ngx/database:/var/lib/postgresql/data",
        ]
      }
      template {
        env = true
        destination = "${NOMAD_SECRET_DIR}/config.env"
        data = <<-EOF
          {{- with secret "kv/apps/paperless/postgresql" }}
            POSTGRES_DB={{ .Data.data.database }}
            POSTGRES_USER={{ .Data.data.username }}
            POSTGRES_PASSWORD={{ .Data.data.password }}
          {{- end }}
        EOF
      }
      resources {
        cpu = 1024
        memory = 512
      }
      service {
        name = "paperless-ngx-db"
        port = "db"
      }

      vault {
        role = "paperless"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        file        = true
      }
    }
  }
}
