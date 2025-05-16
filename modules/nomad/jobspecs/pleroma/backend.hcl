job "pleroma-backend" {
  datacenters = ["cascadia"]

  group "database" {
    count = 1

    network {
      port "postgres" { to = 5432 }
    }

    task "postgres" {
      driver = "docker"

      template {
        data = <<EOF
        {{- with secret "kv/apps/pleroma/postgresql" }}
          DB_USER = "{{ .Data.data.username }}"
          DB_PASS = "{{ .Data.data.password }}"
          DB_NAME = "{{ .Data.data.database }}"
        {{ end }}
        EOF
        destination = "config.env"
        env = true
      }

      config {
        image = "postgres:12.1-alpine"
        ports = ["postgres"]
        volumes = [
          "/mnt/nfs/pleroma/postgres:/var/lib/postgresql/data",
        ]
      }

      resources {
        cpu = 512
        memory = 256
        memory_max = 1024
      }

      service {
        name = "pleroma-postgres"
        port = "postgres"
      }
    }
  }

  vault {
    role = "pleroma"
  }
}
