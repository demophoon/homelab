variable "image_version" {
  type = string
  default = "2024.05.13-0-5-g9cd0780"
}
variable "region" {
  type = string
}

job "resume" {
  datacenters = ["digitalocean", "cascadia"]
  region = var.region

  spread {
    attribute = "${node.unique.name}"
    weight    = 100
  }

  update {
    max_parallel = 2
    canary = 2
    health_check = "checks"
    min_healthy_time = "30s"
    auto_revert = true
    auto_promote = true
  }

  group "app" {
    count = 2

    network {
      port "app" { to = 8080 }
    }

    task "resume" {
      driver = "docker"

      config {
        image = "registry.services.demophoon.com/demophoon/resume:${var.image_version}"
        image_pull_timeout = "15m"

        ports = ["app"]
      }
      resources {
        cpu = 64
        memory = 64
      }

      service {
        name = "resume"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.resume.rule=host(`resume.brittg.com`)",
        ]
        canary_tags = [
          "traefik.enable=true",
          "traefik.http.routers.resume-canary.rule=host(`resume-canary.brittg.com`)",
        ]
        check {
          type     = "http"
          name     = "app_health"
          path     = "/"
          interval = "20s"
          timeout  = "5s"
        }
      }
    }
  }
}
