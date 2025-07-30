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
    }

    task "registry" {
      driver = "docker"

      env {
        #REGISTRY_AUTH = "htpasswd"
        #REGISTRY_AUTH_HTPASSWD_PATH = "/auth/htpasswd"
        #REGISTRY_AUTH_HTPASSWD_REALM = "demophoon.registry"
      }

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
        ports = ["registry"]
      }

      resources {
        cpu = 256
        memory = 128
        memory_max = 512
      }

      service {
        name = "${TASK}"
        tags = [
          "traefik.enable=true"
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
  }
}
