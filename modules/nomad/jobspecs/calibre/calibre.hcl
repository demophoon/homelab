variable "image_version" {
  type = string
}

job "calibre" {
  datacenters = ["cascadia"]

  group "calibre-web" {
    count = 1

    network {
      port "app" { to = 8083 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "crocodilestick/calibre-web-automated:V${var.image_version}"
        volumes = [
          "/mnt/nfs/calibre/config:/config",
          "/mnt/nfs/calibre/library:/calibre-library",
        ]
        ports = ["app"]
      }
      resources {
        cpu = 512
        memory = 512
      }
      env {
        TZ = "America/Los_Angeles"
        PUID = "1000"
        PGID = "1000"
      }

      service {
        name = "calibre-web"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.calibre-web.rule=Host(`books.brittg.com`)",
        ]
      }
    }
  }
}
