job "immich-backend" {
  datacenters = ["cascadia"]

  group "postgres" {
    volume "db" {
      type = "host"
      source = "immich-database"
    }

    network {
      port "postgres" { to = 5432 }
    }

    task "postgres" {
      driver = "docker"
      volume_mount {
        volume      = "db"
        destination = "/var/lib/postgresql/data"
      }
      config {
        image = "ghcr.io/immich-app/postgres:14-vectorchord0.3.0-pgvectors0.2.0"
        ports = ["postgres"]
      }
      template {
        data = <<-EOF
          {{ with secret "kv/apps/immich/postgresql" }}
          POSTGRES_DB="{{ .Data.data.database }}"
          POSTGRES_USER="{{ .Data.data.username }}"
          POSTGRES_PASSWORD="{{ .Data.data.password }}"
          POSTGRES_INITDB_ARGS='--data-checksums'
          {{ end }}
        EOF
        destination = "local/env"
        env = true
      }
      resources {
        cpu = 400
        memory = 256
        memory_max = 1024
      }
      service {
        name = "immich-postgres"
        port = "postgres"
      }
    }
  }

  group "cache" {
    network {
      port "redis" { to = 6379 }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "docker.io/redis:6.2-alpine"
        ports = ["redis"]
      }
      resources {
        cpu = 200
        memory = 128
        memory_max = 1024
      }
      service {
        name = "immich-redis"
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

  vault {
    policies = ["immich"]
  }
}
