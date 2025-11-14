//  docker run -d -p 8080:8080 --name=podgrab -v "/host/path/to/assets:/assets" -v "/host/path/to/config:/config"  akhilrex/podgrab

job "podgrab" {
  datacenters = ["cascadia"]

  group "podgrab" {
    count = 1

    network {
      port "app" { to = 8080 }
    }

    task "podgrab" {
      driver = "docker"

      config {
        image = "akhilrex/podgrab:latest"
        ports = ["app"]
        volumes = [
          "/mnt/media/Podcasts:/assets",
          "/mnt/nfs/podgrab/config:/config",
        ]
      }

      resources {
        cpu = 512
        memory = 256
      }

      template {
        data = <<-EOF
          CHECK_FREQUENCY=30
        EOF
        destination = "local/env"
        env = true
      }

      service {
        name = "podgrab"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.podgrab.rule=host(`podcast.brittg.com`)",
          "traefik.http.routers.podgrab.middlewares=authentik",
        ]
      }

      service {
        name = "podgrab-internal"
        port = "app"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.podgrab-internal.rule=host(`podcast.internal.demophoon.com`)",
        ]
      }
    }
  }
}
