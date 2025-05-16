job "miniflux-app" {
  datacenters = ["cascadia"]

  group "app" {
    count = 1

    network {
      port "app" { to = 8080 }
    }

    task "miniflux" {
      driver = "docker"

      config {
        image = "docker.io/miniflux/miniflux:latest"
        ports = ["app"]
      }

      template {
        destination = "local/config.env"
        data = <<-EOF
        {{ with secret "kv/apps/miniflux/postgresql" }}
        {{- range service "miniflux-db" }}
        DATABASE_URL = "postgres://{{ .Data.data.username }}:{{ .Data.data.password }}@{{ .Address }}:{{ .Port }}/{{ .Data.data.database }}?sslmode=disable"
        {{ end }}
        {{ end }}

        {{ with secret "kv/apps/miniflux/app" }}
        ADMIN_USERNAME="{{ .Data.data.admin_username }}"
        ADMIN_PASSWORD="{{ .Data.data.admin_password }}"
        {{ end }}
        EOF
        env = true
      }

      env {
        RUN_MIGRATIONS = 1
        BASE_URL = "https://reader.brittg.com"
      }

      resources {
        cpu = 256
        memory = 256
      }

      service {
        name = "miniflux"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.miniflux-app.rule=Host(`reader.brittg.com`)",
        ]
      }
    }
  }
}
