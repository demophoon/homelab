variable "image_version" {
  type = string
  default = "2.0.72" # image: factoriotools/factorio
}

job "factorio" {
  datacenters = ["cascadia"]
  group "server" {
    volume "server" {
      type            = "host"
      source          = "lynx-aux-1"
    }

    network {
      port "srv" { to = 34197 }
   }

    task "factorio" {
      driver = "docker"

      volume_mount {
        volume      = "server"
        destination = "/server"
      }

      config {
        image = "factoriotools/factorio:${var.image_version}"
        ports = ["srv"]
        volumes = [
          "/mnt/lynx-aux-1/factorio-spaceage:/factorio",
        ]
      }

      resources {
        cpu = 1600
        memory = 256
        memory_max = 4096
      }
      service {
        name = "factorio"
        port = "srv"
        tags = [
          "traefik.enable=true",
          "traefik.udp.routers.factorio-srv.entrypoints=factorio",
        ]
      }
    }
  }

}
