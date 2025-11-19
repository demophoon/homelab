variable "image_version" {
  type = string
  default = "sha-951992b"
}

job "valheim" {
  datacenters = ["cascadia"]
  group "server" {
    volume "server" {
      type            = "host"
      source          = "proxmox-aux-1"
    }

    network {
      port "srv" { to = 2456 }
      port "srv2" { to = 2457 }
      port "http" { to = 80 }
    }

    task "valheim" {
      driver = "docker"

      volume_mount {
        volume      = "server"
        destination = "/vh"
      }

      config {
        image = "lloesche/valheim-server:${var.image_version}"
        ports = ["srv", "srv2", "http"]
        volumes = [
          "/mnt/proxmox-aux-1/valheim/data:/opt/valheim",
          "/mnt/proxmox-aux-1/valheim/config:/config",
        ]
      }

      template {
        data = <<-EOT
          SERVER_NAME="Brittle Hollow"
          WORLD_NAME="brittlehollow"
          SERVER_PUBLIC="true"
          ADMINLIST_IDS="76561198024471694"

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
        memory = 256
        memory_max = 4096
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

      vault {
        role = "valheim"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        file        = true
        ttl         = "1h"
      }
    }
  }
}
