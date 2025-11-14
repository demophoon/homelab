variable "image_version" {
  type = string
  default = "1.27.12"
}

job "syncthing" {
    datacenters = ["cascadia"]

    affinity {
      attribute = "${meta.provider}"
      operator  = "!="
      value     = "raspberrypi"
      weight    = 80
    }

    group "app" {
        count = 1

        volume "syncthing" {
          type      = "host"
          source    = "syncthing"
        }

        network {
            port "app" { static = 22000 }
            port "http" { to = 8384 }
        }

        task "syncthing" {
            driver = "docker"
            env {
              PUID = "1000"
              PGID = "1000"
            }

            config {
                image = "syncthing/syncthing:${var.image_version}"
                ports = ["app", "http"]
            }
            volume_mount {
                volume      = "syncthing"
                destination = "/var/syncthing"
            }
            resources {
                cpu = 4096
                memory = 512
            }

            service {
                name = "${TASK}"
                port = "http"
                tags = [
                  # Enable Traefik
                  "traefik.enable=true",
                ]
            }
        }
    }
}
