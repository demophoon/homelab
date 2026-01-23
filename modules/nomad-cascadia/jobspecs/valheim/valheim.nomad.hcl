variable "image_version" {
  type = string
  default = "sha-9220bdc"
}

job "valheim" {
  datacenters = ["cascadia"]
  group "server" {
    volume "server" {
      type            = "host"
      source          = "lynx"
    }

    network {
      port "srv" { to = 2456 }
      port "srv2" { to = 2457 }
      port "http" { to = 80 }
      port "map" { to = 3000 }
    }

    task "valheim" {
      driver = "docker"

      volume_mount {
        volume      = "server"
        destination = "/vh"
      }

      config {
        image = "ghcr.io/community-valheim-tools/valheim-server:${var.image_version}"
        ports = ["srv", "srv2", "http", "map"]
        volumes = [
          "/mnt/lynx/valheim/data:/opt/valheim",
          "/mnt/lynx/valheim/config:/config",
        ]
      }

      template {
        data = <<-EOT
          SERVER_NAME="Brittle Hollow"
          WORLD_NAME="brittlehollow"
          SERVER_PUBLIC="true"
          ADMINLIST_IDS="76561198024471694"

          BEPINEX="true"

          {{ with secret "kv/data/apps/valheim" }}
          SERVER_PASS="{{ .Data.data.password }}"
          {{ end }}

          STATUS_HTTP="true"
        EOT
        destination = "local/config"
        env = true
        # TODO: Activate in Nomad 1.10.0+
        #once = true
      }

      resources {
        cpu = 2000
        memory = 4096
        memory_max = 8192
      }
      service {
        name = "valheim-2456"
        port = "srv"
        tags = [
          "traefik.enable=true",
          "traefik.udp.routers.valheim-2456.entrypoints=valheim",
        ]
      }

      service {
        name = "valheim-2457"
        port = "srv2"
        tags = [
          "traefik.enable=true",
          "traefik.udp.routers.valheim-2457.entrypoints=valheim2",
        ]
      }

      service {
        name = "valheim-http"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.valheim-status.rule=host(`valheim.brittg.com`)",
        ]
      }

      service {
        name = "valheim-map"
        port = "map"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.valheim-map.rule=host(`valheim-map.brittg.com`)",
        ]
      }

      vault {
        role = "valheim"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
