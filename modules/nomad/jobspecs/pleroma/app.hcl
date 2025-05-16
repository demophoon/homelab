job "pleroma-app" {
  datacenters = ["cascadia"]

  group "app" {
    count = 1

    network {
      port "app" { to = 4000 }
    }

    task "pleroma" {
      driver = "docker"

      env {
        INSTANCE_NAME = "brittslittlesliceofheaven"
        DOMAIN = "social.brittg.com"

        ADMIN_EMAIL = "pleroma@brittg.com"
        NOTIFY_EMAIL = "pleroma-notify@brittg.com"
      }

      template {
        data = <<EOF
        {{- range service "pleroma-postgres" }}
          DB_HOST={{ .Address }}
          DB_PORT={{ .Port }}
        {{ end }}

        {{- with secret "kv/apps/pleroma/postgresql" }}
          DB_USER = "{{ .Data.data.username }}"
          DB_PASS = "{{ .Data.data.password }}"
          DB_NAME = "{{ .Data.data.database }}"
        {{ end }}
        EOF
        destination = "config.env"
        env = true
      }

      config {
        # Built from github.com/angristan/docker-pleroma with openssl-dev patch
        image = "registry.internal.demophoon.com/pleroma/pleroma:develop"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/pleroma/uploads:/var/lib/pleroma/uploads",
          "/mnt/nfs/pleroma/static:/var/lib/pleroma/static",
          "/mnt/nfs/pleroma/config/config.exs:/etc/pleroma/config.exs:ro",
        ]
      }

      resources {
        cpu = 512
        memory = 512
        memory_max = 2048
      }

      service {
        name = "pleroma-app"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.pleroma-app.rule=Host(`social.brittg.com`)",
        ]
      }
    }
  }

  vault {
    role = "pleroma"
  }
}
