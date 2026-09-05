variable "image_version" {
  type    = string
  default = "3.5.2" # image: ghcr.io/neptunehub/audiomuse-ai
}

job "audiomuse-workers" {
  datacenters = ["cascadia"]

  group "audiomuse-worker" {
    scaling {
      enabled = true
      min     = 1
      max     = 6
    }

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    task "audiomuse-worker" {
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
          SERVICE_TYPE = "worker"
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
        EOF
        env = true
        destination = "local/audiomuse.env"
      }

      config {
        image = "ghcr.io/neptunehub/audiomuse-ai:${var.image_version}"
        image_pull_timeout = "15m"
      }

      resources {
        cpu = 512
        memory = 512
        memory_max = 4096
      }
    }
  }
}
