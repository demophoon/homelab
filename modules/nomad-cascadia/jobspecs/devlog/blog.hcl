variable "region" {
  type = string
}

job "devlog" {
  datacenters = ["cascadia", "digitalocean"]
  region = var.region

  group "devlog" {
    count = 2

    network {
      port "nginx" { to = 80 }
    }

    task "devlog" {
      driver = "docker"

      config {
        image = "registry.services.demophoon.com/demophoon/devlog:91430c9551f84ebd2884ec9b28f03e6732697909-072325"
        ports = ["nginx"]
      }
      resources {
        cpu = 64
        memory = 64
      }

      service {
        name = "${TASK}"
        port = "nginx"
        tags = [
          # Enable Traefik
          "traefik.enable=true",

          # devlog.brittg.com
          "traefik.http.routers.devlog.rule=host(`devlog.brittg.com`)",
        ]
      }
    }
  }
}
