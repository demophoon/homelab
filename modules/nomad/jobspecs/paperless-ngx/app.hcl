variable "image_version" {
  type = string
  default = "2.16.3" # image: ghcr.io/paperless-ngx/paperless-ngx
}

job "paperless" {
  datacenters = ["cascadia"]

  group "app" {
    count = 1
    network {
      port "app"       { to = 8000 }
    }

    task "paperless" {
      driver = "docker"
      config {
        image = "ghcr.io/paperless-ngx/paperless-ngx:latest"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/paperless-ngx/server/data:/usr/src/paperless/data",
          "/mnt/nfs/paperless-ngx/server/media:/usr/src/paperless/media",
          "/mnt/nfs/paperless-ngx/server/export:/usr/src/paperless/export",
          "/mnt/nfs/paperless-ngx/server/consume:/usr/src/paperless/consume",
        ]
      }
      env {
        PAPERLESS_URL = "https://docs.internal.demophoon.com"
      }
      template {
        destination = "config.env"
        env = true
        data = <<-EOF
        {{- with secret "kv/apps/paperless/app" }}
        PAPERLESS_SECRET_KEY = "{{ .Data.data.secret_key }}"
        {{- end}}

        {{- range service "paperless-ngx-broker" }}
        PAPERLESS_REDIS = redis://{{ .Address }}:{{ .Port }}
        {{- end }}

        PAPERLESS_APPS = allauth.socialaccount.providers.openid_connect
        PAPERLESS_REDIRECT_LOGIN_TO_SSO=true

        {{- with secret "kv/apps/paperless/oauth" }}
        PAPERLESS_SOCIALACCOUNT_PROVIDERS = '{ "openid_connect": { "APPS": [ { "provider_id": "authentik", "name": "Authentik", "client_id": "{{ .Data.data.client_id }}", "secret": "{{ .Data.data.client_secret }}", "settings": { "server_url": "{{ .Data.data.provider_url }}" } } ], "OAUTH_PKCE_ENABLED": "True" } }'
        {{- end }}
        EOF
      }
      resources {
        cpu = 2048
        memory = 2048
        memory_max = 4096
      }

      service {
        name = "paperless-ngx-app"
        port = "app"
        tags = [
          # Enable Traefik
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.paperless-ngx.rule=host(`docs.internal.demophoon.com`)",
        ]
        check {
          name = "s3-console"
          type = "http"
          interval = "30s"
          timeout = "10s"
          path = "/"
        }
      }
    }
  }

  group "persistance" {
    count = 1
    network {
      port "broker"    { to = 6379 }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "docker.io/library/redis:7"
        ports = ["broker"]
        volumes = [
          "/mnt/nfs/paperless-ngx/broker:/data",
        ]
      }
      resources {
        cpu = 256
        memory = 128
      }
      service {
        name = "paperless-ngx-broker"
        port = "broker"
      }
    }
  }

  vault {
    role = "paperless"
  }
}
