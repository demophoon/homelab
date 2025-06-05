variable "image_version" {
  type = string
  default = "0.49.0" # image: ghcr.io/dgtlmoon/changedetection.io
}

job "changedetection" {
  datacenters = ["cascadia"]
  region = "global"
  group "app" {
    network {
      port "app" { to = 5000 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "ghcr.io/dgtlmoon/changedetection.io:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/changedetection/data:/datastore",
        ]
      }

      resources {
        cpu = 512
        memory = 256
        memory_max = 1024
      }

      service {
        name = "changedetection"
        port = "app"
        tags = [
          "internal=true",
          #"traefik.enable=true",
          #"traefik.http.routers.changedetection-app.rule=host(`notes.brittg.com`)",
        ]
      }
    }

  }
}
