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
        image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:739cdd626151ff1f796dc95a6591b55a714f341c737e27f045019ceabf8e8c52"
        ports = ["postgres"]
        command = "postgres"
        args = [
          "-c", "shared_preload_libraries=vectors.so",
          "-c", "search_path='immich', public, vectors",
          "-c", "logging_collector=on",
          "-c", "max_wal_size=2GB",
          "-c", "shared_buffers=512MB",
          "-c", "wal_compression=on",
        ]
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
        cpu = 512
        memory = 512
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
        cpu = 512
        memory = 512
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
    role = "immich"
  }
}
