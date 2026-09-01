variable "image_version" {
  type    = string
  default = "3.5.1" # image: ghcr.io/neptunehub/audiomuse-ai
}

job "audiomuse" {
  datacenters = ["cascadia"]

  group "audiomuse" {
    count = 1

    network {
      port "app" { to = 8000 }
    }

    task "audiomuse" {
      driver = "docker"

      vault {
        role = "audiomuse"
      }

      identity {
        name = "vault_default"
        ttl  = "15m"
        aud  = ["demophoon.com"]
      }

      template {
        data = <<-EOF
          SERVICE_TYPE = "flask"
          TZ = "UTC"

          {{ with secret "kv/data/apps/audiomuse" }}
          POSTGRES_USER = "{{ .Data.data.username }}"
          POSTGRES_PASSWORD = "{{ .Data.data.password }}"
          POSTGRES_DB = {{ .Data.data.database }}
          {{ end }}

          POSTGRES_HOST = "postgres-nas.service.consul.demophoon.com"
          POSTGRES_PORT = "5432"

          {{- range service "audiomuse-redis" }}
          REDIS_URL = "redis://{{ .Address }}:{{ .Port }}/0"
          {{ end }}

          TEMP_DIR = "/tmp/temp_audio"

          NUM_RECENT_ALBUMS = 10
        EOF
        env = true
        destination = "local/audiomuse.env"
      }

      config {
        image = "ghcr.io/neptunehub/audiomuse-ai:${var.image_version}"
        image_pull_timeout = "15m"
        ports = ["app"]
      }

      resources {
        cpu = 512
        memory = 512
        memory_max = 4096
      }
      service {
        name = "audiomuse"
        port = "app"
        tags = [
          "internal=true",
          "traefik.enable=true",
          "traefik.http.routers.audiomuse.rule=Host(`audiomuse.internal.demophoon.com`)",
        ]

      }
    }
  }
}
