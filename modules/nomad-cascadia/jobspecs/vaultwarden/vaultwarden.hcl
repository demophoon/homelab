variable "image_version" {
  type = string
  default = "1.30.1"
}

job "vaultwarden" {
  datacenters = ["cascadia"]

  group "vaultwarden" {
    count = 1

    volume "vaultwarden" {
      type = "host"
      source = "vaultwarden"
    }

    network {
      port "app" { to = 5242 }
    }

    task "vaultwarden" {
      driver = "docker"

      template {
          destination = "${NOMAD_SECRETS_DIR}/env"
          env = true
          data = <<-EOF
            DOMAIN = "https://vaultwarden.services.demophoon.com"
            ROCKET_PORT = 5242

            {{ with secret "kv/apps/vaultwarden/app" }}
              PUSH_ENABLED = "true"
              PUSH_INSTALLATION_ID = "{{ .Data.data.push_installation_id }}"
              PUSH_INSTALLATION_KEY = "{{ .Data.data.push_installation_key }}"
            {{ end }}

            {{ with secret "kv/apps/smtp" }}
              SMTP_HOST = "{{ .Data.data.host }}"
              SMTP_PORT = {{ .Data.data.port }}
              SMTP_FROM = "vaultwarden@brittg.com"
              SMTP_FROM_NAME = "Vaultwarden"
              SMTP_USERNAME = "{{ .Data.data.username }}"
              SMTP_PASSWORD = "{{ .Data.data.password }}"
            {{ end }}
          EOF
        }

      config {
        image = "vaultwarden/server:${var.image_version}"
        image_pull_timeout = "15m"
        ports = ["app"]
      }

      volume_mount {
        volume = "vaultwarden"
        destination = "/data"
      }
      resources {
        cpu = 512
        memory = 256
        memory_max = 1024
      }
      service {
        name = "${TASK}"
        port = "app"
        tags = [
          "traefik.enable=true"
        ]

        check {
          name     = "http check"
          type     = "http"
          port     = "app"
          path     = "/api/config"
          interval = "5s"
          timeout  = "2s"
        }

      }


      vault {
        role = "vaultwarden"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
