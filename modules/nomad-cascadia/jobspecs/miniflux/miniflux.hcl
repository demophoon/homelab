job "miniflux" {
  datacenters = ["cascadia"]
  node_pool   = "all"

  group "miniflux" {
    count = 1

    network {
      port "app" { to = 8080 }
    }

    task "app" {
      driver = "docker"
      config {
        image = "ghcr.io/miniflux/miniflux"
        ports = ["app"]
      }

      template {
        destination = "local/config.env"
        data = <<-EOF
        {{ with secret "kv/apps/miniflux/postgresql" }}
        DATABASE_URL="postgres://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres-nas.service.consul.demophoon.com:5432/{{ .Data.data.database }}?sslmode=disable"
        {{ end }}
        RUN_MIGRATIONS=1
        BASE_URL="https://reader.brittg.com"
        EOF
        env = true
      }

      resources {
        cpu = 200
        memory = 128
        memory_max = 512
      }

      service {
        name = "miniflux"
        port = "app"
        tags = [
          # Enable Traefik
          "traefik.enable=true",
          "traefik.http.routers.miniflux.rule=host(`reader.brittg.com`)",
        ]
      }

      vault {
        role = "miniflux"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
