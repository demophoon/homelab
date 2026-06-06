variable "image_version" {
  type = string
  default = "v0.3.1" # image: gabehf/koito
}

job "koito" {
  datacenters = ["cascadia"]

  group "app" {

    network {
      port "app" { to = 4110 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "gabehf/koito:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/koito/data:/etc/koito",
        ]
      }

      template {
        data = <<-EOT
          APP_ENV=production
          {{ with secret "kv/apps/koito/database" }}
          #KOITO_DATABASE_URL="postgresql://{{ .Data.data.username }}:{{ .Data.data.password_encoded }}@postgres-nas.service.consul.demophoon.com:5432/{{ .Data.data.database }}"
          {{ end }}

          {{ with secret "kv/apps/koito/config" }}
          KOITO_LASTFM_API_KEY="{{ .Data.data.lastfm_api_key }}"
          KOITO_LBZ_RELAY_TOKEN="{{ .Data.data.lbz_relay_token }}"
          {{ end }}
          KOITO_FETCH_IMAGES_DURING_IMPORT=true
          KOITO_ENABLE_LBZ_RELAY=true
          KOITO_LBZ_RELAY_URL="https://api.listenbrainz.org/1"
        EOT
        destination = "secrets/config"
        env = true
      }

      resources {
        cpu = 400
        memory = 512
        memory_max = 4096
      }
      service {
        name = "koito"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.koito.rule=host(`as.brittg.com`) || host(`koito.brittg.com`)",
        ]
      }

      vault {
        role = "koito"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}


