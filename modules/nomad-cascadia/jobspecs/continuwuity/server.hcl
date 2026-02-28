variable "image_version" {
  type = string
  default = "v0.5.5" # image: forgejo.ellis.link/continuwuation/continuwuity
}

job "continuwuity" {
  datacenters = ["cascadia"]

  group "continuwuity" {

    volume "server" {
      type            = "host"
      source          = "lynx"
    }

    network {
      port "app" { to = 6167 }
    }

    task "app" {
      driver = "docker"

      volume_mount {
        volume      = "server"
        destination = "/srv"
      }

      config {
        image = "forgejo.ellis.link/continuwuation/continuwuity:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/lynx/continuwuity/data:/var/lib/continuwuity",
        ]
      }

      template {
        data = <<-EOT
          CONTINUWUITY_SERVER_NAME=matrix.brittg.com
          CONTINUWUITY_DATABASE_PATH=/var/lib/continuwuity
          CONTINUWUITY_LOG=warn,state_res=warn
          CONTINUWUITY_PORT=6167
          CONTINUWUITY_MAX_REQUEST_SIZE=20000000
          CONTINUWUITY_ALLOW_REGISTRATION=false
          {{ with secret "kv/data/apps/continuwuity/app" }}
            CONTINUWUITY_REGISTRATION_TOKEN={{ .Data.data.token }}
          {{ end }}
          CONTINUWUITY_ALLOW_FEDERATION=true
          CONTINUWUITY_ALLOW_CHECK_FOR_UPDATES=true
          CONTINUWUITY_TRUSTED_SERVERS=["matrix.org"]
          CONTINUWUITY_ADDRESS=0.0.0.0
          CONTINUWUITY_WELL_KNOWN="{client=https://matrix.brittg.com, server=matrix.brittg.com:443}"
        EOT
        destination = "secrets/config"
        env = true
      }

      resources {
        cpu = 400
        memory = 1024
        memory_max = 4096
      }
      service {
        name = "matrix"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.continuwuity.rule=Host(`matrix.brittg.com`) || (Host(`brittg.com`) && PathPrefix(`/.well-known/matrix`))",
          "traefik.http.routers.to-continuwuity.middlewares=matrix-cors-headers",
          "traefik.http.middlewares.matrix-cors-headers.headers.accessControlAllowOriginList=*",
          "traefik.http.middlewares.matrix-cors-headers.headers.accessControlAllowHeaders=Origin, X-Requested-With, Content-Type, Accept, Authorization",
          "traefik.http.middlewares.matrix-cors-headers.headers.accessControlAllowMethods=GET, POST, PUT, DELETE, OPTIONS",
        ]
      }

      vault {
        role = "continuwuity"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
