variable "ha_version" {
  type = string
  default = "2026.6.4" # image: homeassistant/home-assistant
}

job "homeassistant-studio" {
  datacenters = ["cascadia"]
  priority = 100
  node_pool = "studio"

  group "homeassistant" {
    count = 1
    restart { mode = "delay" }

    network {
      port "homeassistant" {
        to = 8123
        static = 8123
      }
    }
    volume "zigbee" {
      type = "host"
      source = "sonoff-radio"
    }
    volume "homeassistant" {
      type = "host"
      source = "homeassistant"
    }

    task "homeassistant" {
      driver = "docker"

      config {
        network_mode = "host"
        image = "homeassistant/home-assistant:${var.ha_version}"
        privileged = true
        volumes = [
          "/run/dbus:/run/dbus:ro",
          "/etc/localtime:/etc/localtime:ro",
        ]
      }
      volume_mount {
        volume = "homeassistant"
        destination = "/config"
      }
      volume_mount {
        volume = "zigbee"
        destination = "/dev/zigbee"
      }

      resources {
        cpu = 1000
        memory = 512
        memory_max = 2048
      }

      service {
        name = "homeassistant-studio"
        port = "homeassistant"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.homeassistant-studio.rule=Host(`studio.flawedfauna.com`) || Host(`studio.services.demophoon.com`)",
        ]
        check {
          name     = "http check"
          type     = "http"
          port     = "homeassistant"
          path     = "/manifest.json"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }

}
