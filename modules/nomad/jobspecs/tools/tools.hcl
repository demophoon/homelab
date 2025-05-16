// docker run -d --name it-tools --restart unless-stopped -p 8080:80 corentinth/it-tools:latest

job "it-tools" {
  datacenters = ["digitalocean"]
  region = "digitalocean"

  group "tools" {
    count = 1

    network {
      port "app" { to = 80 }
    }

    task "it-tools" {
      driver = "docker"

      config {
        image = "corentinth/it-tools:latest"
        image_pull_timeout = "15m"
        ports = ["app"]
      }

      resources {
        cpu = 32
        memory = 16
      }

      service {
        name = "it-tools"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.it-tools.rule=host(`tools.brittg.com`)",
        ]
      }
    }
  }
}
