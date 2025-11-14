job "bliss" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  group "bliss" {
    count = 1

    network {
      port "app" { static = 3220 }
      port "app2" { static = 3221 }
    }

    volume "media" {
      type = "host"
      source = "plex-media"
    }
    volume "arr" {
      type = "host"
      source = "plex-arr"
    }

    task "bliss" {
      driver = "docker"

      user = "1000"

      config {
        image = "elstensoftware/bliss:latest"
        ports = ["app", "app2"]

        volumes = [
          "/mnt/dank0/andromeda/bliss:/config",
        ]
      }

      volume_mount {
        volume = "media"
        destination = "/media"
      }
      volume_mount {
        volume = "arr"
        destination = "/Downloads"
      }

      resources {
        cpu = 4096
        memory = 1024
        memory_max = 4096
      }

      service {
        name = "bliss-ui"
        port = "app"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.bliss-internal.rule=Host(`bliss.internal.demophoon.com`)",
        ]
      }
    }
  }

}
