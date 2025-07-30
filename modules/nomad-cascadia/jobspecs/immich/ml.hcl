variable "image_version" {
  type = string
  default = "v1.113.0"
}

job "immich-ml" {
  datacenters = ["cascadia", "mobile"]

  affinity {
    attribute = "${node.datacenter}"
    value     = "mobile"
    weight    = 100
  }

  group "machine-learning" {
    network {
      port "ml" { static = 3003 }
    }

    task "machine-learning" {
      driver = "docker"

      template {
        data = <<EOF
IMMICH_VERSION=v1.102.3
EOF
        destination = "local/env"
        env = true
      }

      config {
        image = "ghcr.io/immich-app/immich-machine-learning:${var.image_version}"
        ports = ["ml"]
        volumes = [
          "/mnt/nfs/immich/cache:/cache"
        ]
      }
      resources {
        cpu = 4096
        memory = 2048
        memory_max = 4096
      }
      service {
        name = "immich-machine-learning"
        port = "ml"
      }
    }
  }
}
