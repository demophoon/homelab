variable "image_version" {
  type    = string
  default = "3.5.1" # image: ghcr.io/neptunehub/audiomuse-ai
}

job "audiomuse-backend" {
  datacenters = ["cascadia"]

  group "redis" {
    count = 1

    network {
      port "redis" { static = 6379 }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "docker.io/library/redis:alpine"
        ports = ["redis"]
      }

      service {
        name = "audiomuse-redis"
        port = "redis"
      }
    }

  }
}
