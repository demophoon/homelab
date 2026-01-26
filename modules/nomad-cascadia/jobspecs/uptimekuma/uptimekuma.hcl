variable "image_version" {
  type = string
  default = "2.0.2"
}

job "uptime-kuma" {
  datacenters = ["cascadia"]

  group "uptime-kuma" {
    volume "server" {
      type            = "host"
      source          = "lynx"
    }
    network {
      port "app" { to = 3001 }
    }

    task "app" {
      driver = "docker"
      volume_mount {
        volume      = "server"
        destination = "/srv"
      }
      config {
        image = "louislam/uptime-kuma:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/lynx/uptime-kuma/data:/app/data",
        ]
      }
      template {
        data = <<-EOT
          UPTIME_KUMA_DB_TYPE=mariadb

          {{- range service "mariadb-nas" }}
            UPTIME_KUMA_DB_HOSTNAME={{ .Address }}
            UPTIME_KUMA_DB_PORT={{ .Port }}
          {{- end }}

          {{ with secret "kv/data/apps/uptimekuma/database" }}
            UPTIME_KUMA_DB_NAME={{ .Data.data.database }}
            UPTIME_KUMA_DB_USERNAME={{ .Data.data.username }}
            UPTIME_KUMA_DB_PASSWORD={{ .Data.data.password }}
          {{ end }}
        EOT
        destination = "secrets/env"
        env = true
      }
      resources {
        cpu = 200
        memory = 256
        memory_max = 1024
      }
      service {
        name = "uptime-kuma"
        port = "app"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.uptime-kuma.rule=host(`status.internal.demophoon.com`)",
        ]
      }
      service {
        name = "uptime-kuma-public"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.uptime-kuma-public.rule=host(`status.brittg.com`)",
        ]
      }
      vault {
        role = "uptimekuma"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}

