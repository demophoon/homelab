variable "image_version" {
  type    = string
  default = "0.22.1" # image: superseriousbusiness/gotosocial
}

job "gotosocial" {
  datacenters = ["cascadia"]

  group "gotosocial" {
    network {
      port "app" { to = 8080 }
    }

    task "app" {
      driver = "docker"

      resources {
        cpu = 200
        memory = 512
        memory_max = 1024
      }

      service {
        name = "gotosocial"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.gotosocial.rule=host(`gts.brittg.com`)",
        ]
      }

      vault {
        role = "gotosocial"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }

      config {
        image = "superseriousbusiness/gotosocial:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/gotosocial/storage:/gotosocial/storage",
        ]
      }

      template {
        data = <<-EOT
          GTS_HOST = "gts.brittg.com"
          GTS_DB_TYPE = "postgres"

          {{ with secret "kv/data/apps/gotosocial/db" }}
            GTS_DB_POSTGRES_CONNECTION_STRING = "postgres://{{ .Data.data.username }}:{{ .Data.data.password }}@postgres-nas.service.consul.demophoon.com:5432/{{ .Data.data.database }}"
          {{ end }}

          {{ with secret "kv/apps/smtp" }}
            GTS_SMTP_HOST = "{{ .Data.data.host }}"
            GTS_SMTP_PORT = {{ .Data.data.port }}
            GTS_SMTP_FROM = "gotosocial@brittg.com"
            GTS_SMTP_DISPLAY_NAME = "GoToSocial Admin"
            GTS_SMTP_USERNAME = "{{ .Data.data.username }}"
            GTS_SMTP_PASSWORD = "{{ .Data.data.password }}"
          {{ end }}

          GTS_LETSENCRYPT_ENABLED = "false"

          # Disabled until a local, stable storage path is configured.
          #GTS_WAZERO_COMPILATION_CACHE = /gotosocial/.cache

          GTS_TRUSTED_PROXIES = "100.64.0.0/10"
        EOT
        destination = "secrets/config"
        env = true
      }

    }
  }
}

