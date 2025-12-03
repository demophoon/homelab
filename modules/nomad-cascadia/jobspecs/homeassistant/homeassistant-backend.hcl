job "homeassistant-backend" {
  datacenters = ["cascadia"]
  priority = 100

  affinity {
    attribute = "${unique.consul.name}"
    operator  = "regexp"
    value     = "^proxmox-.*"
    weight    = 100
  }

  constraint {
    attribute = "${meta.region}"
    value     = "cascadia"
  }

  group "appdaemon" {
    count = 1
    restart { mode = "delay" }

    volume "appdaemon" {
      type = "host"
      source = "appdaemon"
    }
    network {
      port "appdaemon"  {
        to = 5050
        static = 5050
      }
    }
    task "appdaemon" {
      driver = "docker"

      config {
        network_mode = "host"
        image = "acockburn/appdaemon:4.4.2"
        image_pull_timeout = "15m"
        ports = ["appdaemon"]
      }
      volume_mount {
        volume = "appdaemon"
        destination = "/conf"
      }
      template {
        data = <<EOF
{{- range service "ha" }}
ha_url: http://{{ .Address }}:{{ .Port }}
{{- end }}
        EOF
        destination = "local/secrets.yaml"
      }
      resources {
        cpu = 200
        memory = 256
        memory_max = 512
      }
      service {
        name = "had"
        port = "appdaemon"
        tags = [
          "traefik.enable=true",

          "traefik.http.middlewares.had-redirect.redirectregex.regex=^https?://had.cascadia.demophoon.com/",
          "traefik.http.middlewares.had-redirect.redirectregex.replacement=https://had.services.demophoon.com/",
          "traefik.http.routers.had.rule=host(`had.services.demophoon.com`) || host(`had.cascadia.demophoon.com`)",
          "traefik.http.routers.had.middlewares=had-redirect",
        ]
      }
    }
  }

  group "mqtt-server" {
    count = 1
    restart { mode = "delay" }

    network {
      port "mqtt-unencrypted" {
        to = 1883
        static = 1883
      }
    }
    volume "mosquitto" {
      type = "host"
      source = "mosquitto"
    }
    task "mosquitto" {
      driver = "docker"
      config {
        image = "eclipse-mosquitto:1.6"
        ports = ["mqtt-unencrypted"]
      }
      volume_mount {
        volume = "mosquitto"
        destination = "/mosquitto"
      }
      resources {
        cpu = 200
        memory = 256
        memory_max = 512
      }
      service {
        name = "mosquitto"
        port = "mqtt-unencrypted"
      }
    }
  }

  group "esphome" {
    count = 0
    restart { mode = "delay" }

    network {
      port "esp" { static = 6052 }
    }

    task "esphome" {
      driver = "docker"
      config {
        network_mode = "host"
        image = "ghcr.io/esphome/esphome:latest"
        image_pull_timeout = "15m"
        privileged = true
        volumes = [
          "/mnt/nfs/gpool0/services/homeassistant/esphome:/config",
          "/etc/localtime:/etc/localtime:ro",
        ]
        ports = ["esp"]
      }
      resources {
        cpu = 100
        memory = 256
        memory_max = 2048
      }
      service {
        name = "espweb"
        port = "esp"
        tags = [
          "internal=true",
        ]
      }
    }
  }
}
