job "authentik-backend" {
  datacenters = ["cascadia"]
  region = "global"

  group "persistance" {
    count = 1
    network {
      port "db" { to = 5432 }
      port "redis" { to = 6379 }
    }

    task "postgresql" {
      driver = "docker"
      config {
        image = "docker.io/library/postgres:16-alpine"
        ports = ["db"]
        volumes = [
          "/mnt/nfs/authentik/db:/var/lib/postgresql/data",
        ]
      }
      resources {
        cpu = 512
        memory = 384
        memory_max = 1024
      }
      template {
        destination = "local/config.env"
        data = <<-EOF
          {{ with secret "kv/apps/authentik/postgresql" }}
          POSTGRES_DB="{{ .Data.data.database }}"
          POSTGRES_USER="{{ .Data.data.username }}"
          POSTGRES_PASSWORD="{{ .Data.data.password }}"
          {{ end }}
        EOF
        env = true
      }
      service {
        name = "authentik-postgres"
        port = "db"
        check {
          type    = "script"
          command = "pg_isready"
          args    = [
            "-d", "$${POSTGRES_DB}",
            "-U", "$${POSTGRES_USER}",
          ]
          interval  = "5s"
          timeout   = "2s"
        }
      }

      vault {
        role = "authentik"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        file        = true
      }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "docker.io/library/redis:alpine"
        ports = ["redis"]
        volumes = [
          "/mnt/nfs/authentik/redis:/data",
        ]
        args = [
          "--save", "60", "1",
          "--loglevel", "warning",
        ]
      }
      resources {
        cpu = 512
        memory = 384
        memory_max = 1024
      }
      service {
        name = "authentik-redis"
        port = "redis"
        check {
          type    = "script"
          command = "/bin/sh"
          args    = ["-c", "redis-cli ping | grep -q PONG"]
          interval  = "5s"
          timeout   = "2s"
        }
      }
    }
  }
}

