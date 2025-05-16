job "miniflux-backend" {
  datacenters = ["cascadia"]

  group "backend" {
    count = 1

    network {
      port "db" { to = 5432 }
    }

    task "miniflux-db" {
      driver = "docker"

      config {
        image = "postgres:15"
        image_pull_timeout = "15m"
        ports = ["db"]
        volumes = [
          "/mnt/nfs/miniflux/db:/var/lib/postgresql/db",
        ]
      }

      template {
        destination = "local/config.env"
        data = <<-EOF
        {{ with secret "kv/apps/miniflux/postgresql" }}
        POSTGRES_DB = "{{ .Data.data.database }}"
        POSTGRES_USER = "{{ .Data.data.username }}"
        POSTGRES_PASSWORD = "{{ .Data.data.password }}"
        {{ end }}
        EOF
        env = true
      }

      resources {
        cpu = 256
        memory = 256
      }

      service {
        name = "miniflux-db"
        port = "db"
      }
    }
  }
}
