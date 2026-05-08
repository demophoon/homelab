variable "image_version" {
  type = string
  default = "v1.13.0-alpha" # image: registry.services.demophoon.com/tangled-org/knot
}

job "tangled-knot" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  group "knot" {
    network {
      port "app" { to = 5555 }
      port "ssh" {
        static = 2222
        to = 22
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "registry.services.demophoon.com/tangled-org/knot:${var.image_version}"
        ports = ["app", "ssh"]
        volumes = [
          "/mnt/dank0/andromeda/tangled/knot/repositories:/home/git/repositories",
          "/mnt/dank0/andromeda/tangled/knot/keys:/etc/ssh/keys",
          "/mnt/dank0/andromeda/tangled/knot/server:/app",
        ]
      }

      template {
        data = <<-EOT
          KNOT_SERVER_HOSTNAME = knot.brittg.com
          KNOT_SERVER_OWNER = did:plc:evt37vxklh6vllnuevsemdcy
          KNOT_SERVER_PORT = 443
          KNOT_SERVER_DB_PATH = /app/knotserver.db
          KNOT_REPO_SCAN_PATH = /home/git/repositories
          KNOT_SERVER_INTERNAL_LISTEN_ADDR = localhost:5444
        EOT
        destination = "local/config"
        env = true
      }

      resources {
        cpu = 200
        memory = 256
        memory_max = 512
      }

      service {
        name = "tangled-knot"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.tangled-knot.rule=host(`knot.brittg.com`)",
        ]
      }

      service {
        name = "tangled-ssh"
        port = "ssh"
      }
    }
  }
}


