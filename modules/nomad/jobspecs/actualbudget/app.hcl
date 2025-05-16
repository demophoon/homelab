job "actualbudget-app" {
  datacenters = ["cascadia"]
  group "app" {
    network {
      port "app" { to = 5006 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "docker.io/actualbudget/actual-server:24.2.0-alpine"
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
        name = "actualbudget"
        port = "app"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.actualbudget.rule=host(`budget.internal.demophoon.com`)",
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
