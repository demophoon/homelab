job "jfs-metadata" {
  datacenters = ["cascadia"]

  group "metadata" {
    network {
      port "redis" {
        to = 6379
        static = 19736
      }
    }

    task "juicefs-metadata" {
      driver = "docker"

      config {
        image = "redis"
        volumes = ["/mnt/nfs/juicefs/metadata:/data"]
        ports = ["redis"]
      }

      resources {
        cpu    = 100
        memory = 256
      }
      service {
        name = "jfs-metadata"
        port = "redis"
      }
    }
  }
}
