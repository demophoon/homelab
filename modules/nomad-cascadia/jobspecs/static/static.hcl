job "static" {
  datacenters = ["cascadia"]

  group "fileserver" {
    count = 3

    volume "static" {
      type      = "host"
      source    = "local-static"
      read_only = true
    }

    network {
      port "nginx" { to = 80 }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:latest"
        image_pull_timeout = "15m"

        ports = ["nginx"]
      }
      volume_mount {
        volume      = "static"
        destination = "/usr/share/nginx/html"
      }
      resources {
        cpu = 64
        memory = 64
        memory_max = 512
      }

      service {
        name = "${TASK}"
        port = "nginx"
        tags = [
          # Enable Traefik
          "traefik.enable=true",

          # factoids.brittg.com
          "traefik.http.routers.factoids-old.rule=host(`assets.brittg.com`) && PathPrefix(`/factoids/`)",
          "traefik.http.routers.factoids.rule=host(`factoid.brittg.com`) || host(`factoids.brittg.com`)",
          "traefik.http.routers.factoids.middlewares=factoids-static",
          "traefik.http.middlewares.factoids-static.addPrefix.prefix=/factoids",

          # cci-emoji.services.demophoon.com
          "traefik.http.routers.cciemoji.rule=host(`cci-emoji.brittg.com`)",
          "traefik.http.routers.cciemoji.middlewares=cciemoji-static",
          "traefik.http.middlewares.cciemoji-static.addPrefix.prefix=/emoji",

          # assets.brittg.com
          "traefik.http.routers.assets.rule=host(`assets.brittg.com`)",
          "traefik.http.routers.assets.middlewares=assets-static",
          "traefik.http.middlewares.assets-static.addPrefix.prefix=/assets",

          # htdocs.brittg.com
          "traefik.http.routers.htdocs.rule=host(`htdocs.brittg.com`)",
          "traefik.http.routers.htdocs.middlewares=htdocs-static",
          "traefik.http.middlewares.htdocs-static.addPrefix.prefix=/htdocs",

          # pico-8.brittg.com
          "traefik.http.routers.pico8.rule=host(`pico-8.brittg.com`)",
          "traefik.http.routers.pico8.middlewares=pico8-static",
          "traefik.http.middlewares.pico8-static.addPrefix.prefix=/pico-8",
        ]
      }
    }
  }
}
