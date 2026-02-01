variable "image_version" {
  type = string
  default = "0.24.4" # image: ghcr.io/usememos/memos
}

job "memos-app" {
  datacenters = ["cascadia"]
  node_pool   = "nas"

  group "app" {
    network {
      port "app" { to = 5230 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "ghcr.io/usememos/memos:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/dank0/andromeda/memos/data:/var/opt/memos",
        ]
      }

      resources {
        cpu = 100
        memory = 512
      }

      service {
        name = "memos-app"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.memos-app.rule=host(`notes.brittg.com`)",
        ]
      }
    }

  }
}
