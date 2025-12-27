job "jellyfin" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  group "jellyfin" {
    count = 1

    network {
      port "app" { static = 8096 }
    }

    volume "config" {
      type = "host"
      source = "jellyfin-config"
    }

    volume "media" {
      type = "host"
      source = "plex-media"
    }
    volume "arr" {
      type = "host"
      source = "plex-arr"
    }

    task "jellyfin" {
      driver = "docker"

      env {
        JELLYFIN_PublishedServerUrl = "https://jellyfin.brittg.com"
      }

      config {
        image = "jellyfin/jellyfin:latest"
        image_pull_timeout = "15m"
        ports = ["app"]

        volumes = [
          "/tmp/jellyfin-cache:/cache",
        ]
      }

      volume_mount {
        volume = "config"
        destination = "/config"
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
        cpu = 512
        memory = 1024
        memory_max = 8192
      }
      service {
        name = "jellyfin-nas"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.jellyfin-nas.rule=Host(`jellyfin.brittg.com`)",
        ]

      }
    }
  }
}
