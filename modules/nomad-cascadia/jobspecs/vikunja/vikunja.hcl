variable "image_version" {
  type = string
  default = "1.0.0" # image: vikunja/vikunja
}

job "vikunja-app" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  group "vikunja" {
    count = 1

    network {
      port "app" { to = 3456 }
    }

    task "app" {
      driver = "docker"

      template {
        data = <<EOF
          {{ with secret "kv/data/apps/vikunja" }}
            VIKUNJA_SERVICE_JWTSECRET = "{{ .Data.data.jwtsecret }}"
          {{ end }}

          VIKUNJA_SERVICE_PUBLICURL = "https://tasks.brittg.com/"
          VIKUNJA_DATABASE_PATH = "/data/db/vikunja.db"
          VIKUNJA_FILES_BASEPATH = "/data/files"
          VIKUNJA_SERVICE_ENABLEREGISTRATION = "false"
          VIKUNJA_SERVICE_TIMEZONE = "America/Los_Angeles"

          {{ with secret "kv/apps/smtp" }}
            VIKUNJA_MAILER_ENABLED = "true"
            VIKUNJA_MAILER_FROMEMAIL = "tasks@brittg.com"
            VIKUNJA_MAILER_AUTHTYPE = "login"
            VIKUNJA_MAILER_HOST = "{{ .Data.data.host }}"
            VIKUNJA_MAILER_PORT = "{{ .Data.data.port }}"
            VIKUNJA_MAILER_USERNAME = "{{ .Data.data.username }}"
            VIKUNJA_MAILER_PASSWORD = "{{ .Data.data.password }}"
          {{ end }}

          VIKUNJA_LOG_MAIL = "stderr"
        EOF
        destination = "secrets/config.env"
        env = true
      }

      config {
        image = "vikunja/vikunja:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/dank0/andromeda/vikunja/db:/data/db",
          "/mnt/dank0/andromeda/vikunja/files:/data/files",
          "/mnt/dank0/andromeda/vikunja/config:/etc/vikunja",
        ]
      }
      resources {
        cpu = 100
        memory = 512
      }
      service {
        name = "vikunja"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.vikunja.rule=host(`tasks.brittg.com`)",
        ]
      }

      vault {
        role = "vikunja"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }

}
