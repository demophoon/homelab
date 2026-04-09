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

      check {
        name     = "runner-alive"
        type     = "script"
        command  = "/bin/sh"
        args     = ["-c", "pgrep -f act_runner"]
        interval = "30s"
        timeout  = "5s"
      }
    }

    # -------------------------------------------------------------------------
    # Task: forgejo-runner
    # -------------------------------------------------------------------------

    task "forgejo-runner" {
      driver = "docker"

      vault {
        role = "forgejo-runner"
      }

      identity {
        name = "vault_default"
        ttl  = "15m"
        aud  = ["demophoon.com"]
      }

      config {
        image        = "gitea/act_runner:0.2.11"
        network_mode = "host"
        privileged   = true

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock",
          "local/config.yaml:/config.yaml:ro",
          "/usr/local/share/ca-certificates:/usr/local/share/ca-certificates:ro",
        ]

        # Use daemon mode with config file
        args = ["daemon", "--config", "/config.yaml"]
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
    - "docker:docker://ubuntu:latest"

cache:
  enabled: true
  dir: /data/cache

container:
  network: host
  privileged: true
  options: "--dns=8.8.8.8"
  valid_volumes:
    - /usr/local/share/ca-certificates
  docker_host: unix:///var/run/docker.sock
EOF
        destination = "local/config.yaml"
      }

      # --- Registration Token from Vault ---
      # Use internal Forgejo address to bypass oauth2-proxy
      template {
        data = <<-EOF
GITEA_INSTANCE_URL=http://{{ range service "forgejo" }}{{ .Address }}:{{ .Port }}{{ end }}
{{- with secret "kv/apps/forgejo/runner" }}
GITEA_RUNNER_REGISTRATION_TOKEN={{ .Data.data.registration_token }}
{{- end }}
GITEA_RUNNER_NAME=runner-{{ env "NOMAD_ALLOC_INDEX" }}
GITEA_RUNNER_LABELS=host:host,docker:docker://ubuntu:latest
EOF
        destination = "secrets/runner.env"
        env         = true
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
