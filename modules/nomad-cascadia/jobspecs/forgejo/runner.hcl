variable "dispatcher_version" {
  type    = string
  default = "dc15fa0-1775855159"
}

job "forgejo-runner" {
  region      = "global"
  datacenters = ["cascadia"]
  type        = "service"
  node_pool   = "default"

  update {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "30s"
    healthy_deadline = "5m"
    auto_revert      = true
  }

  # ---------------------------------------------------------------------------
  # Task Group
  # ---------------------------------------------------------------------------

  group "forgejo-runner" {
    count = 2

    # Force allocations onto different nodes
    constraint {
      distinct_hosts = true
    }

    network {
      mode = "host"
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "30s"
      mode     = "fail"
    }

    service {
      name     = "forgejo-runner"
      task     = "forgejo-runner"
    }

    # -------------------------------------------------------------------------
    # Task: runner-credential-vendor
    # -------------------------------------------------------------------------
    task "forgejo-prestart" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      vault {
        role = "forgejo-runner"
      }

      identity {
        name = "vault_default"
        ttl  = "15m"
        aud  = ["demophoon.com"]
      }

      config {
        image        = "alpine:3.18"
        command      = "/local/runner_token.sh"
      }

      # --- Registration Token from Vault ---
      # Use internal Forgejo address to bypass oauth2-proxy
      template {
        data = <<-EOF
        #!/bin/sh

        apk add --no-cache curl jq

        {{ with secret "kv/apps/forgejo/runner" }}
        curl -X 'POST' \
          'https://git.brittg.com/api/v1/admin/actions/runners' \
          -H 'accept: application/json' \
          -H 'Authorization: Bearer {{ .Data.data.registration_token }}' \
          -H 'Content-Type: application/json' \
          -d '{
          "name": "{{ env "NOMAD_ALLOC_NAME" }}-{{ env "NOMAD_SHORT_ALLOC_ID" }}",
          "ephemeral": true
        }' > /alloc/data/registration.json

        jq -r '.token' /alloc/data/registration.json > /alloc/data/token
        jq -r '.uuid' /alloc/data/registration.json > /alloc/data/uuid

        cp /secrets/config.yaml /alloc/data/config.yaml
        echo "      token: $(cat /alloc/data/token)" >> /alloc/data/config.yaml
        echo "      uuid: $(cat /alloc/data/uuid)" >> /alloc/data/config.yaml
        {{ end }}
        EOF
        destination = "local/runner_token.sh"
        perms = "755"
      }

      # --- Runner Configuration ---
      template {
        data = <<-EOF
log:
  level: info

runner:
  file: /data/.runner
  capacity: 1
  timeout: 3h
  insecure: false
  fetch_timeout: 5s
  fetch_interval: 2s
  labels:
    - "host:host"
    - "docker:docker://registry.services.demophoon.com/demophoon/dispatcher:${var.dispatcher_version}"

cache:
  enabled: true
  dir: /data/cache

container:
  network: host
  privileged: true
  valid_volumes:
    - /usr/local/share/ca-certificates
  docker_host: "-"

server:
  connections:
    brittg:
      url: https://git.brittg.com/
EOF
        destination = "secrets/config.yaml"
      }


    }

    # -------------------------------------------------------------------------
    # Task: forgejo-runner
    # -------------------------------------------------------------------------

    task "forgejo-runner" {
      driver = "docker"

      user = "root"

      config {
        image        = "code.forgejo.org/forgejo/runner:12"
        network_mode = "host"
        privileged   = true

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          #"local/config.yaml:/config.yaml:ro",
          "/usr/local/share/ca-certificates:/usr/local/share/ca-certificates:ro",
        ]

        args = ["forgejo-runner", "one-job", "--wait", "--config", "/alloc/data/config.yaml"]
      }

      resources {
        cpu        = 500
        memory     = 128
        memory_max = 1024
      }

      kill_timeout = "60s"
    }
  }
}
