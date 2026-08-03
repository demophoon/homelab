job "arrs" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  # Music
  group "lidarr" {
    count = 1

    network {
      port "lidarr" { static = 8686 }
    }

    volume "lidarr-config" {
      type = "host"
      source = "lidarr"
    }
    volume "media" {
      type = "host"
      source = "plex-media"
    }
    volume "arr" {
      type = "host"
      source = "plex-arr"
    }

    task "lidarr" {
      driver = "docker"
      user = "1000"

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "America/Los_Angeles"
      }

      config {
        #image = "lscr.io/linuxserver/lidarr:latest"
        image = "11notes/lidarr:2.12.4"
        image_pull_timeout = "15m"
        ports = ["lidarr"]
      }

      volume_mount {
        volume = "lidarr-config"
        destination = "/lidarr/etc"
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
        cpu = 2000
        memory = 1024
        memory_max = 2048
      }

      service {
        name = "lidarr"
        port = "lidarr"
        tags = [
          "internal=true",
        ]
      }
      service {
        name = "music"
        port = "lidarr"
        tags = [
          "internal=true",
        ]
      }
    }
  }

  # TV
  group "sonarr" {
    count = 1

    network {
      port "sonarr" { static = 8989 }
    }

    volume "sonarr-config" {
      type = "host"
      source = "sonarr"
    }
    volume "media" {
      type = "host"
      source = "plex-media"
    }
    volume "arr" {
      type = "host"
      source = "plex-arr"
    }

    task "sonarr" {
      driver = "docker"
      user = "1000"

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "America/Los_Angeles"
      }

      config {
        image = "lscr.io/linuxserver/sonarr:latest"
        image_pull_timeout = "15m"
        ports = ["sonarr"]
      }

      volume_mount {
        volume = "sonarr-config"
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
        cpu = 200
        memory = 128
        memory_max = 1024
      }

      service {
        name = "sonarr"
        port = "sonarr"
        tags = [
          "internal=true",
        ]
      }
      service {
        name = "tv"
        port = "sonarr"
        tags = [
          "internal=true",
        ]
      }
    }
  }

  # Movies
  group "radarr" {
    count = 1

    network {
      port "radarr" { static = 7878 }
    }

    volume "radarr-config" {
      type = "host"
      source = "radarr"
    }
    volume "media" {
      type = "host"
      source = "plex-media"
    }
    volume "arr" {
      type = "host"
      source = "plex-arr"
    }

    task "radarr" {
      driver = "docker"
      user = "1000"

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "America/Los_Angeles"
      }

      config {
        image = "lscr.io/linuxserver/radarr:latest"
        image_pull_timeout = "15m"
        ports = ["radarr"]
      }

      volume_mount {
        volume = "radarr-config"
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
        cpu = 200
        memory = 128
        memory_max = 1024
      }

      service {
        name = "radarr"
        port = "radarr"
        tags = [
          "internal=true",
        ]
      }
      service {
        name = "movies"
        port = "radarr"
        tags = [
          "internal=true",
        ]
      }
    }
  }

  # Trackers
  group "jackett" {
    count = 1

    network {
      port "jackett" { static = 9117 }
    }

    volume "jackett-config" {
      type = "host"
      source = "jackett"
    }

    task "jackett" {
      driver = "docker"
      user = "1000"

      env {
        PUID = "1000"
        PGID = "1000"
        TZ = "America/Los_Angeles"
      }

      config {
        image = "lscr.io/linuxserver/jackett:latest"
        image_pull_timeout = "15m"
        ports = ["jackett"]
      }

      volume_mount {
        volume = "jackett-config"
        destination = "/config"
      }

      resources {
        cpu = 200
        memory = 128
        memory_max = 1024
      }

      service {
        name = "jackett"
        port = "jackett"
        tags = [
          "internal=true",
        ]
      }
      service {
        name = "trackers"
        port = "jackett"
        tags = [
          "internal=true",
        ]
      }
    }
  }

  group "flaresolverr" {
    count = 1

    network {
      port "flaresolverr" { static = 8191 }
    }

    task "flaresolverr" {
      driver = "docker"

      config {
        image = "ghcr.io/flaresolverr/flaresolverr:latest"
        image_pull_timeout = "15m"
        ports = ["flaresolverr"]
      }

      resources {
        cpu = 200
        memory = 128
        memory_max = 512
      }
    }
  }

}
