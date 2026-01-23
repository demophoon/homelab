variable "image_version" {
  type = string
  //default = "v0.1.64"
  default = "dev"
}

job "donetick" {
  datacenters = ["cascadia"]

  group "donetick" {

    volume "server" {
      type            = "host"
      source          = "lynx"
    }

    network {
      port "app" { to = 2021 }
    }

    task "app" {
      driver = "docker"

      volume_mount {
        volume      = "server"
        destination = "/srv"
      }

      config {
        image = "registry.internal.demophoon.com/donetick/donetick:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/lynx/donetick/data:/donetick-data",
          "/mnt/lynx/donetick/assets:/app/assets",
        ]
      }

      template {
        data = <<-EOT
          DT_ENV=selfhosted

          DT_IS_DONE_TICK_DOT_COM=false
          DT_IS_USER_CREATION_DISABLED=true

          DT_NAME="ADH DoneTick"
          DT_SERVER_PORT=2021
          DT_SERVE_FRONTEND=true

          DT_DATABASE_TYPE=postgres
          DT_DATABASE_HOST=cube.node.consul.demophoon.com
          DT_DATABASE_PORT=5432

          {{ with secret "kv/data/apps/donetick/database" }}
            DT_DATABASE_USER={{ .Data.data.username }}
            DT_DATABASE_PASSWORD={{ .Data.data.password }}
            DT_DATABASE_NAME={{ .Data.data.database }}
            DT_DATABASE_MIGRATION=true
          {{ end }}

          {{ with secret "kv/data/apps/donetick/app" }}
            DT_JWT_SECRET="{{ .Data.data.jwt_secret }}"
          {{ end }}

          {{ with secret "kv/data/apps/donetick/oidc" }}
            DT_OAUTH2_NAME="Authentik"
            DT_OAUTH2_CLIENT_ID="{{ .Data.data.client_id }}"
            DT_OAUTH2_CLIENT_SECRET="{{ .Data.data.client_secret }}"

            DT_OAUTH2_REDIRECT_URL="https://donetick.brittg.com/auth/oauth2"
            DT_OAUTH2_AUTH_URL="https://sso.brittg.com/application/o/authorize/"
            DT_OAUTH2_TOKEN_URL="https://sso.brittg.com/application/o/token/"
            DT_OAUTH2_USER_INFO_URL="https://sso.brittg.com/application/o/userinfo/"
          {{ end }}
        EOT
        destination = "secrets/config"
        env = true
      }

      resources {
        cpu = 200
        memory = 256
        memory_max = 4096
      }
      service {
        name = "donetick"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.donetick.rule=host(`donetick.brittg.com`)",
        ]
      }

      vault {
        role = "donetick"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
