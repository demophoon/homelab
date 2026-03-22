job "registry" {
  datacenters = ["cascadia"]
  # The Docker registry *is* pretty important....
  priority = 80

  # If this task was a regular task, we'd use a constraint here instead & set the weight to -100
  affinity {
    attribute   = "${attr.class}"
    value       = "controller"
    weight      = 100
  }

  group "main" {
    count = 1

    volume "data" {
      type = "host"
      source = "registry-data"
    }
    volume "certs" {
      type = "host"
      source = "registry-certs"
    }
    volume "auth" {
      type = "host"
      source = "registry-auth"
    }
    network {
      port "registry" { to = 5000 }
      port "registry-internal" { to = 5000 }
    }

    task "registry-public" {
      driver = "docker"

      volume_mount {
        volume = "data"
        destination = "/var/lib/registry"
        read_only = true
      }
      volume_mount {
        volume = "certs"
        destination = "/certs"
        read_only = true
      }
      volume_mount {
        volume = "auth"
        destination = "/auth"
        read_only = true
      }

      config {
        image = "registry:2"
        image_pull_timeout = "15m"
        ports = ["registry"]
      }

      resources {
        cpu = 256
        memory = 128
        memory_max = 512
      }

      env {
        REGISTRY_STORAGE_MAINTENANCE_READONLY = "{\"enabled\":true}"
      }

      service {
        name = "registry"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.registry.rule=Host(`registry.services.demophoon.com`)",
        ]

        port = "registry"
        check {
          type        = "tcp"
          port        = "registry"
          interval    = "10s"
          timeout     = "3s"
        }
      }
    }

    task "registry-internal" {
      driver = "docker"

      volume_mount {
        volume = "data"
        destination = "/var/lib/registry"
      }
      volume_mount {
        volume = "certs"
        destination = "/certs"
      }
      volume_mount {
        volume = "auth"
        destination = "/auth"
      }

      config {
        image = "registry:2"
        image_pull_timeout = "15m"
        ports = ["registry-internal"]
      }

      resources {
        cpu = 256
        memory = 128
        memory_max = 512
      }

      service {
        name = "registry-internal"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.registry-internal.rule=Host(`registry.internal.demophoon.com`)",
        ]

        port = "registry-internal"
        check {
          type        = "tcp"
          port        = "registry-internal"
          interval    = "10s"
          timeout     = "3s"
        }
      }
    }
  }
}
