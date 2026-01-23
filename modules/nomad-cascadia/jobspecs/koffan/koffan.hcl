variable "image_version" {
  type = string
  default = "v1.2.1"
}

job "koffan" {
  datacenters = ["cascadia"]

  group "koffan" {

    volume "server" {
      type            = "host"
      source          = "lynx-aux-1"
    }

    network {
      port "app" { to = 80 }
    }

    task "app" {
      driver = "docker"

      volume_mount {
        volume      = "server"
        destination = "/srv"
      }

      config {
        image = "ghcr.io/pansalut/koffan:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/lynx-aux-1/koffan/data:/data",
        ]
      }

      template {
        data = <<-EOT
          APP_ENV=production
          {{ with secret "kv/data/apps/koffan" }}
            APP_PASSWORD={{ .Data.data.app_password }}
          {{ end }}
        EOT
        destination = "secrets/config"
        env = true
      }

      resources {
        cpu = 50
        memory = 64
        memory_max = 128
      }
      service {
        name = "koffan"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.koffan.rule=host(`shopping.brittg.com`)",
        ]
      }

      vault {
        role = "koffan"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}

