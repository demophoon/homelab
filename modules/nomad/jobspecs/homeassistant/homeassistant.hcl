variable "ha_version" {
  type = string
  default = "2024.9.0"
}
variable "ha_image" {
  type = string
  default = null
}
variable "zigbee2mqtt_version" {
  type = string
  default = "1.40.0"
}

job "homeassistant-app" {
  datacenters = ["cascadia"]
  priority = 100

  affinity {
    attribute = "${meta.provider}"
    value     = "metal"
    weight    = 100
  }

  affinity {
    attribute = "${unique.consul.name}"
    operator  = "regexp"
    value     = "^proxmox-.*"
    weight    = 100
  }

  group "homeassistant" {
    count = 1
    restart { mode = "delay" }

    network {
      port "homeassistant" {
        to = 8123
        static = 8123
      }
    }
    volume "homeassistant" {
      type = "host"
      source = "homeassistant"
    }
    task "homeassistant" {
      driver = "docker"

      config {
        network_mode = "host"
        image = var.ha_image != null ? var.ha_image : "homeassistant/home-assistant:${var.ha_version}"
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
      resources {
        cpu = 2048
        memory = 768
        memory_max = 3072
      }
      service {
        name = "ha"
        port = "homeassistant"
        tags = [
          "traefik.enable=true",
          "traefik.http.middlewares.ha-redirect.redirectregex.regex=^https?://ha.cascadia.demophoon.com/",
          "traefik.http.middlewares.ha-redirect.redirectregex.replacement=https://ha.services.demophoon.com/",
          "traefik.http.routers.ha.rule=Host(`ha.services.demophoon.com`) || Host(`ha.cascadia.demophoon.com`)",
          "traefik.http.routers.ha.middlewares=ha-redirect",
        ]
      }
      service {
        name = "ha-internal"
        port = "homeassistant"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.ha-internal.rule=Host(`ha.internal.demophoon.com`)",
        ]
      }
    }
  }

  group "zigbee2mqtt" {
    count = 1
    restart {
      mode = "delay"
      delay = "30s"
    }
    network {
      port "ui" { to = 8080 }
    }
    volume "zigbee2mqtt" {
      type = "host"
      source = "zigbee2mqtt"
    }

    task "coordinator" {
      driver = "docker"
      env {
        TZ = "America/Los_Angeles"
      }
      config {
        image = "koenkk/zigbee2mqtt:${var.zigbee2mqtt_version}"
        ports = ["ui"]
      }
      volume_mount {
        volume = "zigbee2mqtt"
        destination = "/app/data"
      }
      template {
        data = <<EOF
{{- range service "mosquitto" }}
ZIGBEE2MQTT_CONFIG_MQTT_SERVER=mqtt://{{ .Address }}:{{ .Port }}
{{- end }}
        EOF
        destination = "local/env"
        env = true
      }
      resources {
        cpu = 512
        memory = 256
        memory_max = 512
      }
      service {
        name = "coordinator"
        port = "ui"
        tags = [
          "internal=true",
        ]
      }
    }
  }

  group "matter" {
    count = 1
    restart {
      mode = "delay"
      delay = "30s"
    }
    network {
      port "matter" { static = 5580 }
    }
    task "server" {
      driver = "docker"
      env {
        TZ = "America/Los_Angeles"
      }
      config {
        network_mode = "host"
        image = "ghcr.io/home-assistant-libs/python-matter-server:stable"
        ports = ["matter"]
        privileged = true
        volumes = [
          "/run/dbus:/run/dbus:ro",
          "/mnt/nfs/gpool0/services/homeassistant/matter:/data",
        ]
      }
      resources {
        cpu = 512
        memory = 256
        memory_max = 512
      }
      service {
        name = "matter"
        port = "matter"
        tags = [
          "internal=true",
        ]
      }

    }
  }
}
