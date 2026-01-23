variable "image_version" {
  type = string
  default = "latest"
}

job "it-tools" {
  datacenters = ["cascadia"]

  group "it-tools" {

    network {
      port "app" { to = 80 }
    }

    task "app" {
      driver = "docker"
      config {
        image = "ghcr.io/corentinth/it-tools:${var.image_version}"
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
