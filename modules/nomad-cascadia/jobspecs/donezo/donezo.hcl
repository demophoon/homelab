variable "image_version" {
  type = string
  default = "0.1.1"
}

job "donezo" {
  datacenters = ["cascadia"]

  group "donezo" {

    network {
      port "backend" { to = 8888 }
      port "ui" { to = 3000 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "git.brittg.com/demophoon/donezo:${var.image_version}"
        ports = ["ui", "backend"]
      }

      resources {
        cpu = 200
        memory = 256
      }

      service {
        name = "donezo-ui"
        port = "ui"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.donezo-ui.rule=host(`donezo.brittg.com`)",
        ]
      }
      service {
        name = "donezo-backend"
        port = "backend"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.donezo-backend.rule=host(`donezo.brittg.com`) && PathPrefix(`/api`)",
        ]
      }

    }
  }
}
