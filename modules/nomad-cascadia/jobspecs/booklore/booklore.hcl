variable "image_version" {
  type = string
  default = "v1.18.3"
}
job "booklore" {
  datacenters = ["cascadia"]

  group "booklore" {
    network {
      port "app" { to = 6000 }
    }

    task "app" {
      driver = "docker"

      template {
        data = <<-EOT
          USER_ID=1000
          GROUP_ID=1000
          TZ=America/Los_Angeles
          BOOKLORE_PORT=6000

          {{ with secret "kv/data/apps/booklore" }}
            DATABASE_USERNAME="{{ .Data.data.username }}"
            DATABASE_PASSWORD="{{ .Data.data.password }}"
          {{ end }}

          {{- range service "mariadb-nas" }}
            DATABASE_URL=jdbc:mariadb://{{ .Address }}:{{ .Port }}/booklore
          {{- end }}
        EOT
        destination = "secrets/config"
        env = true
      }

      config {
        image = "ghcr.io/booklore-app/booklore:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/booklore/data:/app/data",
          "/mnt/nfs/booklore/books:/books",
          "/mnt/nfs/booklore/bookdrop:/bookdrop",
        ]
      }

      resources {
        cpu    = 200
        memory = 256
        memory_max = 1024
      }

      service {
        name = "booklore"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.booklore.rule=Host(`books.brittg.com`)",
        ]
      }

      vault {
        role = "booklore"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
