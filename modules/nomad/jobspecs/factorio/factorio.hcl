# password
# refactor2hell

variable "image_version" {
  type = string
  default = "1.1.104"
}

job "factorio" {
  datacenters = ["cascadia"]

  affinity {
    attribute = "${attr.unique.consul.name}"
    operator  = "regexp"
    value     = "nuc"
    weight    = -100
  }

  group "factorio" {
    count = 1

    network {
      port "server" { }
    }

    task "factorio-server" {
      driver = "docker"

      config {
        image = "factoriotools/factorio:${var.image_version}"
        ports = [
          "server",
        ]
        volumes = [
          "/mnt/nfs/factorio-2024:/factorio",
        ]
      }

      env {
        BIND = "0.0.0.0"
        PORT = "${NOMAD_PORT_server}"
      }

      resources {
        cpu = 4096
        memory = 2048
        memory_max = 4096
      }

      service {
        name = "factorio"
        port = "server"
        tags = [
          "traefik.enable=true",
          "traefik.udp.routers.factorioserver.entrypoints=factorio",
        ]
      }

    }
  }
}
