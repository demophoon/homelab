variable "image_version" {
  type    = string
  default = "latest"
}

job {
  region      = "global"
  datacenters = ["cascadia"]
  type        = "batch"
  node_pool   = "default"

  periodic {
    cron = "0 7 * * *"
    prohibit_overlap = true
  }

  group "renovate" {
    count = 1

    network {
      mode = "host"
    }

    task "renovate" {
      driver = "docker"

      vault {
        role = "renovate"
      }

      identity {
        name = "vault_default"
        ttl  = "15m"
        aud  = ["demophoon.com"]
      }

      config {
        image = "renovate/renovate:${var.image_version}"
      }

      template {
        data = <<-EOF
        module.exports = {
          platform: 'forgejo',
          endpoint: 'https://git.brittg.com/api/v1/',
          gitAuthor: 'Renovate Bot <git+renovate@demophoon.com>',
          username: 'renovate-bot',
          autodiscover: true,
          onboardingConfig: {
            $schema: 'https://docs.renovatebot.com/renovate-schema.json',
            extends: ['local>meta/renovate'],
          },
          optimizeForDisabled: true,
          persistRepoData: true,
          allowedCommands: ['^.*$'],
        };
        EOF
        destination = "local/config.js"
      }

      template {
        data = <<-EOF
          RENOVATE_CONFIG_FILE=/local/config.js
          {{- with secret "kv/apps/renovate" }}
          RENOVATE_TOKEN={{ .Data.data.token }}
          {{- end }}
        EOF
        env         = true
        destination = "secret/env"
      }

      resources {
        cpu        = 100
        memory     = 64
        memory_max = 256
      }

    }
  }
}
