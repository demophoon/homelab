job "nextcloud-backend" {
  datacenters = ["cascadia"]

  # Redis Cache
  group "cache" {
    count = 1
    network {
      port "redis" {
        static = 9736
        to = 6379
      }
    }
    task "redis" {
      driver = "docker"
      config {
        image = "redis"
        image_pull_timeout = "15m"
        ports = ["redis"]
      }
      resources {
        cpu = 1024
        memory = 512
      }
    }
    service {
      name = "nextcloud-redis"
      port = "redis"
      check {
        name     = "redis_probe"
        type     = "tcp"
        interval = "10s"
        timeout  = "1s"
      }
    }
  }
}
