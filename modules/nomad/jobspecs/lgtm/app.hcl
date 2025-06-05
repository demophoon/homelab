variable "image_version" {
  type = string
  default = "0.8.4" # image: ghcr.io/grafana/docker-otel-lgtm
}

job "lgtm" {
  datacenters = ["cascadia"]

  group "lgtm" {
    network {
      port "grafana" { to = 3000 }
      port "prometheus" { to = 9090 } # 4318
      port "otel-collector-http" { to = 4318 }
    }

    task "app" {
      driver = "docker"

      env {
        GF_PATHS_DATA = "/data/grafana"
      }

      config {
        image = "ghcr.io/grafana/docker-otel-lgtm:v${var.image_version}"
        ports = ["grafana", "prometheus", "otel-collector-http"]
        volumes = [
          "/mnt/nfs/lgtm/grafana:/data/grafana",
          "/mnt/nfs/lgtm/prometheus:/data/prometheus",
          "/mnt/nfs/lgtm/loki:/data/loki",
        ]
      }

      resources {
        cpu = 512
        memory = 1024
      }

      service {
        name = "grafana"
        port = "grafana"
        tags = [
          "internal=true",
          "traefik.enable=true",
          "traefik.http.routers.grafana.rule=host(`grafana.internal.demophoon.com`)",
        ]
      }

      service {
        name = "prometheus"
        port = "prometheus"
        tags = [
          "internal=true",
          "traefik.enable=true",
          "traefik.http.routers.prometheus.rule=host(`prometheus.internal.demophoon.com`)",
        ]
      }

      service {
        name = "otel-http"
        port = "otel-collector-http"
        tags = [
          "internal=true",
          "traefik.enable=true",
          "traefik.http.routers.otel.rule=host(`otel.internal.demophoon.com`)",
        ]
      }

    }

  }
}
