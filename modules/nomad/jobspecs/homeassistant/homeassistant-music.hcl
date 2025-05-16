# docker run --network host --privileged -v <dir>:/data ghcr.io/music-assistant/server
job "homeassistant-music" {
  datacenters = ["cascadia"]
  priority = 100

  group "music-assistant" {
    count = 1
    restart { mode = "delay" }

    network {
      port "app" {
        static = 8095
      }
    }

    task "music-assistant" {
      driver = "docker"

      config {
        network_mode = "host"
        image = "ghcr.io/music-assistant/server"
        privileged = true
        volumes = [
          "/mnt/nfs/gpool/services/homeassistant/music-assistant:/data",
        ]
      }

      resources {
        cpu = 512
        memory = 256
        memory_max = 1024
      }

      service {
        name = "music-assistant"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.music-assistant.rule=Host(`ma.services.demophoon.com`)",
        ]
      }
      service {
        name = "music-assistant-internal"
        port = "app"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.music-assistant-internal.rule=Host(`ma.internal.demophoon.com`)",
        ]
      }
    }
  }

}
