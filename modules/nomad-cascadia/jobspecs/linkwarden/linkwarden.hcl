variable "image_version" {
  type = string
  default = "v2.13.2"
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

//  linkwarden:
//    env_file: .env
//    environment:
//      - DATABASE_URL=postgresql://postgres:${POSTGRES_PASSWORD}@postgres:5432/postgres
//    restart: always
//    # build: . # uncomment to build from source
//    image: ghcr.io/linkwarden/linkwarden:latest # comment to build from source
//    ports:
//      - 3000:3000
//    volumes:
//      - ./data:/data/data
//    depends_on:
//      - postgres
//      - meilisearch
//  meilisearch:
//    image: getmeili/meilisearch:v1.12.8
//    restart: always
//    env_file:
//      - .env
//    volumes:
//      - ./meili_data:/meili_data
