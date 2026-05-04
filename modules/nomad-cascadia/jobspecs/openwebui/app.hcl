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
        image = "ghcr.io/open-webui/open-webui:v0.9.2-ollama"
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
          OLLAMA_BASE_URL="http://192.168.1.34:11434"
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
        ]
      }

    }
  }
}
