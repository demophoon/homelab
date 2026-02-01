variable "image_version" {
  type = string
  default = "13"
}

job "forgejo" {
  datacenters = ["cascadia"]

  constraint {
    attribute = "${meta.region}"
    value     = "cascadia"
  }

  group "app" {
    count = 1

    network {
      port "app" { to = 3000 }
      port "ssh" { to = 22 }
    }

    task "forgejo" {
      driver = "docker"

      config {
        image = "codeberg.org/forgejo/forgejo:${var.image_version}"
        image_pull_timeout = "15m"
        ports = ["app", "ssh"]
        volumes = [
          "/mnt/nfs/forgejo/data:/data",
          "/etc/localtime:/etc/localtime:ro",
        ]
      }

      template {
         data = <<EOF
           USER_UID=1000
           USER_GID=1000
         EOF
         destination = "/local/config.env"
         env = true
      }

      resources {
        cpu = 500
        memory = 512
        memory_max = 2048
      }

      service {
        name = "forgejo"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.forgejo-app.rule=Host(`git.brittg.com`)",
        ]
      }

      service {
        name = "forgejo-ssh"
        port = "ssh"
        tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.forgejo-ssh.rule=HostSNI(`*`)",
          "traefik.tcp.routers.forgejo-ssh.entrypoints=ssh",
        ]
      }

    }
  }
}

