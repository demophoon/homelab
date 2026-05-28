job "${name}" {
  datacenters = ["cascadia"]

  # ---------------------------------------------------------------------------
  # Task Group
  # ---------------------------------------------------------------------------

  group "${name}-${environment}" {
    count = 1

    network {
      %{ for service in services }
      port "${service.name}" { to = ${service.port} }
      %{ endfor }
    }

    # -------------------------------------------------------------------------
    # Task: main app
    # -------------------------------------------------------------------------

    task "${name}" {
      driver = "docker"

      # Service Definitions
      %{ for service in services }
      service {
        name = "${name}-${service.name}"
        port = "${service.name}"
        tags = [
          %{ for tag in service.tags }
          "${tag}",
          %{ endfor }
        ]
      }
      %{ endfor }

      %{ if vault_role != "" }
      # Vault Identity and Role
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "15m"
      }

      vault {
        role = "${vault_role}"
      }
      %{ endif }

      config {
        image = "${image}:${image_version}"
        ports = [
          %{ for service in services }
          "${service.name}",
          %{ endfor }
        ]
      }

      resources {
        cpu = ${cpu}
        memory = ${memory}
        memory_max = ${memory_max}
      }

    }
  }
}

