variable "image_version" {
  type    = string
  default = "26.4.0" # image: actualbudget/actual-server
}

job "actualbudget-app" {
  datacenters = ["cascadia"]
  group "app" {
    network {
      port "app" { to = 5006 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "docker.io/actualbudget/actual-server:${var.image_version}-alpine"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/actualbudget:/data",
        ]
      }
      resources {
        cpu = 128
        memory = 128
        memory_max = 512
      }
      service {
        name = "budget"
        port = "app"
        tags = [
          "internal=true",
        ]

        check {
          name     = "http check"
          type     = "http"
          port     = "app"
          path     = "/info"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }
}
