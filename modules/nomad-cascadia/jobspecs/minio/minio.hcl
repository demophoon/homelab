job "minio" {
  datacenters = ["cascadia"]

  group "minio" {
    count = 1

    network {
      port "data"       { to = 9000 }
      port "console"    { to = 9001 }
    }
    volume "objects" {
      type   = "host"
      source = "minio"
    }

    task "minio" {
      driver = "docker"
      config {
        image = "quay.io/minio/minio:RELEASE.2022-11-17T23-20-09Z"
        command = "server"
        args = [
          "--address", ":9000",
          "--console-address", ":9001",
          "/data",
        ]
        image_pull_timeout = "15m"
        ports = ["data", "console"]
      }

      template {
        destination = "local/config.env"
        data = <<-EOF
        {{ with secret "kv/apps/minio" }}
        MINIO_ROOT_USER="{{ .Data.data.root_username }}"
        MINIO_ROOT_PASSWORD="{{ .Data.data.root_password }}"
        {{ end }}
        EOF
        env = true
      }

      env {
        MINIO_SERVER_URL = "https://s3.brittg.com/"
        MINIO_BROWSER_REDIRECT_URL = "https://s3-console.brittg.com/"
      }

      resources {
        cpu = 2048
        memory = 1024
      }
      volume_mount {
        volume      = "objects"
        destination = "/data"
      }
      service {
        name = "${TASK}-console"
        port = "console"
        tags = [
          # Enable Traefik
          "traefik.enable=true",
          "traefik.http.routers.minio-console.rule=host(`s3-console.brittg.com`) || host(`s3-console.internal.demophoon.com`)",
        ]
        check {
          name = "s3-console"
          type = "http"
          interval = "30s"
          timeout = "10s"
          path = "/"
        }
      }
      service {
        name = "${TASK}-data"
        port = "data"
        tags = [
          # Enable Traefik
          "traefik.enable=true",
          "traefik.http.routers.minio.rule=host(`s3.brittg.com`) || host(`s3.internal.demophoon.com`)",
        ]
      }

      vault {
        role = "minio"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
