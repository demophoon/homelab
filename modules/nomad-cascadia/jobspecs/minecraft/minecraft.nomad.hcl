variable "image_version" {
  type = string
  default = "2025.10.5" # image: itzg/minecraft-server
}
variable "image_flavor" {
  type = string
  default = "java25"
}

job "minecraft" {
  datacenters = ["cascadia"]
  group "server" {
    volume "server" {
      type            = "host"
      source          = "lynx-aux-1"
    }

    network {
      port "srv" { to = 25565 }
   }

    task "minecraft" {
      driver = "docker"

      volume_mount {
        volume      = "server"
        destination = "/server"
      }

      template {
        data = <<-EOF
          EULA = "true"
          TYPE = "PAPER"
          VERSION = "1.21.10"

          ENABLE_WHITELIST = "true"
          WHITELIST_FILE = "/local/whitelist.json"
          OVERRIDE_WHITELIST = "true"
        EOF
        destination = "local/config"
        env = true
      }

      template {
        data = <<-EOF
          #!/bin/sh

          cp /local/whitelist.json /data/whitelist.json
          /usr/local/bin/rcon-cli whitelist reload
          echo "Done"
        EOF
        perms = "700"
        destination = "/local/scripts/reload_whitelist.sh"
      }

      template {
        data = <<-EOF
          {{ key "minecraft/brittg/whitelist" }}
        EOF
        destination = "/local/whitelist.json"
        uid = "1000"
        gid = "1000"
        perms = "644"
        change_mode = "script"
        change_script {
          command = "/bin/sh"
          args = ["-e", "/local/scripts/reload_whitelist.sh"]
          timeout = "1m"
        }
      }

      config {
        image = "itzg/minecraft-server:${var.image_version}-${var.image_flavor}"
        ports = ["srv"]
        volumes = [
          "/mnt/lynx-aux-1/minecraft/data:/data",
        ]
      }

      resources {
        cpu = 1600
        memory = 256
        memory_max = 4096
      }

      service {
        name = "minecraft"
        port = "srv"
        tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.minecraft-srv.rule=HostSNI(`*`)",
          "traefik.tcp.routers.minecraft-srv.entrypoints=minecraft",
        ]
      }
    }

  }

}
