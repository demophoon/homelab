variable "image_version" {
  type = string
  default = "2.9.1" # image: ghcr.io/gotify/server
}

job "gotify" {
  datacenters = ["cascadia"]
  node_pool   = "all"

  group "app" {
    volume "server" {
      type            = "host"
      source          = "digitalocean"
    }

    network {
      port "app" { to = 80 }
    }

    task "server" {
      driver = "docker"

      volume_mount {
        volume      = "server"
        destination = "/srv"
      }

      config {
        image = "ghcr.io/gotify/server:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/digitalocean/gotify/data:/app/data",
        ]
      }

      resources {
        cpu = 100
        memory = 128
        memory_max = 256
      }
      service {
        name = "gotify"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.gotify.rule=host(`notifications.brittg.com`)",
        ]
      }

    }
  }
}


