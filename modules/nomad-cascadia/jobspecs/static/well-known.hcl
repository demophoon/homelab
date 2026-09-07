variable "image_verison" {
  type = string
  default = "1.38.0" # image: busybox
}

job "wellknown" {
  datacenters = ["cascadia"]
  node_pool = "all"

  group "nginx" {
    count = 3

    network {
      port "nginx" { to = 3000 }
    }

    task "nginx" {
      driver = "docker"

      service {
        name = "wellknown"
        port = "nginx"
        tags = [
          # Enable Traefik
          "traefik.enable=true",
          "traefik.http.routers.wellknown.rule=host(`brittg.com`) && PathPrefix(`/.well-known/`)",

          "traefik.http.routers.wellknown-openpgpkey.rule=host(`brittg.com`) && PathPrefix(`/.well-known/openpgpkey/`)",
          "traefik.http.routers.wellknown-openpgpkey.middlewares=wellknown-openpgpkey-headers",
          "traefik.http.middlewares.wellknown-openpgpkey-headers.headers.accessControlAllowOriginList=*",
          "traefik.http.middlewares.wellknown-openpgpkey-headers.headers.customresponseheaders.Content-Type=application/octet-stream",
        ]
      }

      config {
        image = "busybox:${var.image_version}"
        ports = ["nginx"]
        args   = [
          "busybox", "httpd", "-f", "-v", "-p", "3000", "-h", "/local/static"
        ]
      }

      resources {
        cpu = 64
        memory = 64
        memory_max = 512
      }

      template {
        data = base64decode("Cg==")
        destination = "local/static/.well-known/openpgpkey/policy"
      }

      artifact {
        source = "git::https://git.brittg.com/demophoon/homelab//assets/wkd/"
        destination = "local/static/.well-known/openpgpkey/hu/"
      }
    }
  }
}

