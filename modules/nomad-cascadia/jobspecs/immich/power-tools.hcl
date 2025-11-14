job "immich-powertools" {
  datacenters = ["cascadia"]
  region = "global"
  group "app" {
    count = 1

    network {
      port "app" { to = 3000 }
    }

    task "app" {
      driver = "docker"

      template {
        data = <<-EOF
# Postgres
{{- range service "immich-postgres" }}
DB_HOSTNAME={{ .Address }}
DB_HOST={{ .Address }}
DB_PORT={{ .Port }}
{{ with secret "kv/apps/immich/postgresql" }}
DB_DATABASE_NAME="{{ .Data.data.database }}"
DB_USERNAME="{{ .Data.data.username }}"
DB_PASSWORD="{{ .Data.data.password }}"
{{ end }}
{{- end }}

{{ with secret "kv/apps/immich/postgresql" }}
  IMMICH_URL="https://photos.internal.demophoon.com" # Immich URL
  IMMICH_API_KEY="{{ .Data.data.api_key }}" # Immich API Key
{{ end }}
EOF
        destination = "local/env"
        env = true
      }
      config {
        image = "ghcr.io/varun-raj/immich-power-tools:latest"
        ports = ["app"]
      }

      resources {
        cpu = 100
        memory = 256
        memory_max = 512
      }
      service {
        name = "immich-powertools"
        port = "app"
        tags = [
          "internal=true",
          "traefik.enable=true",
          "traefik.http.routers.immich-powertools.rule=host(`immich-tools.internal.demophoon.com`)",
        ]
      }
    }
  }

  vault {
    policies = ["immich"]
  }
}
