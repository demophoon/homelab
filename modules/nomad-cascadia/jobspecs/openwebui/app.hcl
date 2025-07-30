job "openui" {
  datacenters = ["cascadia"]

  group "openui" {
    count = 1

    network {
      port "app" { to = 8080 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "ghcr.io/open-webui/open-webui"
        ports = ["app"]
        volumes = [
          #"/tmp/openwebui:/app/backend/data"
        ]
      }

      template {
        data = <<-EOH
          WEBUI_AUTH=false
          ENABLE_LOGIN_FORM=false
          ENABLE_OAUTH_SIGNUP=false
          OAUTH_MERGE_ACCOUNTS_BY_EMAIL=true
          OLLAMA_BASE_URL="http://192.168.1.163:11434"
          {{- with secret "kv/apps/openwebui/oauth" }}
          OAUTH_CLIENT_ID="{{ .Data.data.client_id }}"
          OAUTH_CLIENT_SECRET="{{ .Data.data.client_secret }}"
          OPENID_PROVIDER_URL="{{ .Data.data.provider_url }}"
          {{- end }}
          OAUTH_SCOPES=openid email profile
          OPENID_REDIRECT_URI="https://ai.brittg.com/oauth/oidc/callback"
          OAUTH_PROVIDER_NAME="Authentik"
          ENABLE_OAUTH_ROLE_MANAGEMENT=true
          OAUTH_ALLOWED_ROLES=admin,user
          OAUTH_ADMIN_ROLES=admin
        EOH
        destination = "local/file.env"
        env         = true
      }

      resources {
        cpu = 512
        memory = 512
        memory_max = 2048
      }

      service {
        name = "openui"
        port = "app"
        tags = [
          "internal=true",
          "traefik.enable=true",
          "traefik.http.routers.openui.rule=host(`ai.internal.demophoon.com`)",
          #"traefik.http.routers.openui.middlewares=authentik@docker",
          #"traefik.http.routers.openui.middlewares=oidc-auth",
        ]
      }

    }
  }

  vault {
    role = "openwebui"
  }
}
