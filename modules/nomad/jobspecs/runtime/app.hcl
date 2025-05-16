// docker run -d --name it-tools --restart unless-stopped -p 8080:80 corentinth/it-tools:latest

job "runtime" {
  datacenters = ["cascadia"]

  group "runtime-app" {
    network {
      port "app" { to = 80 }
      port "app-secure" { to = 443 }
      port "api" { to = 8443 }

      port "clickhouse" { to = 8123 }
      port "postgres" { to = 5432 }
    }

    task "app" {
      driver = "docker"
      config {
        image = "ghcr.io/mirendev/runtime:latest"
        ports = [
          "app",
          "app-secure",
          "api",
        ]
      }
      resources {
        cpu = 1024
        memory = 512
      }
      service {
        name = "runtime"
        port = "app"
      }
    }

    task "clickhouse" {
      driver = "docker"
      config {
        image = "clickhouse/clickhouse-server:latest"
        ports = [
          "clickhouse"
        ]
      }
      env {
        CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT = 1
        CLICKHOUSE_PASSWORD = "default"
      }
      resources {
        cpu = 512
        memory = 256
      }
      service {
        name = "runtime-clickhouse"
        port = "clickhouse"
      }
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres:17"
        ports = [
          "postgres"
        ]
      }
      env {
        POSTGRES_DB = "runtime_prod"
        POSTGRES_PASSWORD = "runtime"
        POSTGRES_USER = "runtime"
      }
      resources {
        cpu = 512
        memory = 256
      }
      service {
        name = "runtime-postgres"
        port = "postgres"
      }
    }

  }
}
