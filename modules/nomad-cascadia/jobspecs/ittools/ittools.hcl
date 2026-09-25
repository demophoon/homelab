variable "image_version" {
  type = string
  default = "2026.7.11" # image: ghcr.io/sharevb/it-tools
}

job "it-tools" {
  datacenters = ["cascadia"]
  node_pool = "all"

  group "it-tools" {

    network {
      port "app" { to = 8080 }
    }

    task "app" {
      driver = "docker"
      config {
        image = "ghcr.io/sharevb/it-tools:${var.image_version}"
        ports = ["app"]
      }
      resources {
        cpu = 50
        memory = 32
        memory_max = 128
      }
      service {
        name = "it-tools"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.ittools.rule=host(`tools.brittg.com`)",
        ]
      }
    }
  }
}
