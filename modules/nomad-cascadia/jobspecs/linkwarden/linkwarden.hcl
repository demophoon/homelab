variable "image_version" {
  type = string
  default = "v2.16.2" # image: ghcr.io/linkwarden/linkwarden
}

job "linkwarden" {
  datacenters = ["cascadia"]

  group "app" {
    network {
      port "http" { to = 3000 }
    }

    task "linkwarden" {
      driver = "docker"

      config {
        image = "ghcr.io/linkwarden/linkwarden:${var.image_version}"
        ports = ["http"]
        volumes = [
          "/mnt/nfs/linkwarden/data:/data/data",
        ]
      }

      template {
        destination = "local/.env"
        data = <<-EOF
          {{ with secret "kv/data/apps/linkwarden" }}
          NEXTAUTH_SECRET="{{ .Data.data.nextauth_secret }}"
          NEXTAUTH_URL="https://bookmarks.brittg.com/api/v1/auth"
          NEXT_PUBLIC_DISABLE_REGISTRATION="true"
          {{ end }}

          {{ with secret "kv/data/apps/postgres-nas" }}
          DATABASE_URL="postgresql://{{ .Data.data.username }}:{{ .Data.data.password }}@100.109.238.50:5432/linkwarden"
          {{ end }}
        EOF
        env = true
      }

      resources {
        cpu = 500
        memory = 512
        memory_max = 2048
      }

      service {
        name = "linkwarden"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.linkwarden.rule=Host(`bookmarks.brittg.com`)",
        ]
        port = "http"
      }

      vault {
        role = "linkwarden"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }

  //group "search" {
  //}
}
