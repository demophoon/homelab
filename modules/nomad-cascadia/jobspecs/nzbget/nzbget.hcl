job "nzbget" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  group "nzbget" {
    count = 1

    network {
      port "nzbget" { static = 6789 }
    }

    volume "config" {
      type = "host"
      source = "nzbget-config"
    }
    volume "media" {
      type = "host"
      source = "plex-media"
    }

    task "nzbget" {
      driver = "docker"

      template {
        data = <<EOF
        TZ=America/Los_Angeles
        EOF
        env = true
        destination = "local/nzbget.env"
      }

      config {
        image = "nzbgetcom/nzbget:latest"

        ports = ["nzbget"]
      }

      volume_mount {
        volume = "config"
        destination = "/config"
      }
      volume_mount {
        volume = "media"
        destination = "/media"
      }

      resources {
        cpu = 300
        memory = 512
        memory_max = 1024
      }

      service {
        name = "nzbget"
        port = "nzbget"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.nzbget-internal.rule=Host(`nzbget.internal.demophoon.com`)",
        ]
      }
    }
  }
}
