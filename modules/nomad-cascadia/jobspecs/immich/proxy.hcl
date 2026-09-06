variable "image_version" {
  type = string
  default = "3.3.1" # image: ghcr.io/alangrainger/immich-public-proxy
}

job "immich-proxy" {
  datacenters = ["cascadia"]
  region = "global"

  group "proxy" {
    count = 1

    network {
      port "app" { to = 3000 }
    }

    task "app" {
      driver = "docker"

      resources {
        cpu = 100
        memory = 256
        memory_max = 512
      }

      service {
        name = "immich-proxy"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.immich-proxy.rule=host(`photos-public.brittg.com`)",
        ]
        check {
          type        = "http"
          port        = "app"
          path        = "/share/healthcheck"
          interval    = "10s"
          timeout     = "3s"
        }
      }

      template {
        data = <<-EOF
          PUBLIC_BASE_URL = "https://photos-public.brittg.com"
          {{ range service "immich-public" }}
          IMMICH_URL: http://{{ .Address }}:{{ .Port }}
          {{ end }}
        EOF
        destination = "local/env"
        env = true
      }

      config {
        image = "ghcr.io/alangrainger/immich-public-proxy:${var.image_version}"
        ports = ["app"]
      }
    }
  }
}

