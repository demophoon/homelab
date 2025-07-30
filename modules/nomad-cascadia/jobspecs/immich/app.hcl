variable "image_version" {
  type = string
  default = "v1.133.0"
}

job "immich-app" {
  datacenters = ["cascadia"]
  group "app" {
    scaling {
      enabled = true
      min     = 1
      max     = 5

      policy {
        check {
          source = "nomad-apm"
          query  = "avg_cpu"

          strategy "threshold" {
            upper_bound = 100
            lower_bound = 70
            delta       = 1
          }
        }

        check {
          source = "nomad-apm"
          query  = "avg_memory"

          strategy "threshold" {
            upper_bound = 100
            lower_bound = 70
            delta       = 1
          }
        }
      }
    }

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    volume "upload" {
      type            = "host"
      source          = "immich-upload"
    }

    network {
      port "app" { static = 3001 }
    }

    task "app" {
      driver = "docker"

      volume_mount {
        volume      = "upload"
        destination = "/usr/src/app/upload"
      }

      template {
        data = <<EOF
# You can find documentation for all the supported env variables at https://immich.app/docs/install/environment-variables
TZ="America/Los_Angeles"

IMMICH_VERSION=v1.102.3

LOG_LEVEL=debug
IMMICH_METRICS=true

HOST="0.0.0.0"
SERVER_PORT=3001

IMMICH_HOST="0.0.0.0"
IMMICH_PORT=3001

# Microservices
MICROSERVICES_PORT=3002
TZ="America/Los_Angeles"

# Machine Learning Service
{{- range service "immich-machine-learning" }}
MACHINE_LEARNING_HOST={{ .Address }}
MACHINE_LEARNING_PORT={{ .Port }}
{{- end }}

# Postgres
{{- range service "immich-postgres" }}
DB_HOSTNAME={{ .Address }}
DB_PORT={{ .Port }}

{{ with secret "kv/apps/immich/postgresql" }}
DB_DATABASE_NAME="{{ .Data.data.database }}"
DB_USERNAME="{{ .Data.data.username }}"
DB_PASSWORD="{{ .Data.data.password }}"
{{ end }}
{{- end }}

# Redis
{{- range service "immich-redis" }}
REDIS_HOSTNAME={{ .Address }}
REDIS_PORT={{ .Port }}
{{- end }}
EOF
        destination = "local/env"
        env = true
      }
      config {
        image = "ghcr.io/immich-app/immich-server:${var.image_version}"
        ports = ["app"]
        volumes = [
          #"/mnt/nfs/nextcloud/data/demophoon/files:/mnt/media",
          "/tmp/empty-dir:/mnt/media",
          "/mnt/nfs/immich/import:/mnt/import",
        ]
      }
      resources {
        cpu = 512
        memory = 1024
        memory_max = 4096
      }
      service {
        name = "immich-app"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.immich-frontend.rule=host(`photos.brittg.com`)",
        ]
      }
      service {
        name = "immich-app-internal"
        port = "app"
        tags = [
          "internal=true",
          "traefik.enable=true",
          "traefik.http.routers.immich-frontend-internal.rule=host(`photos.internal.demophoon.com`)",
        ]
      }
    }
  }

  vault {
    role = "immich"
  }
}
