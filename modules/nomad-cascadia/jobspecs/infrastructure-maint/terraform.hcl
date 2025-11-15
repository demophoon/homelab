job "infrastructure-maintenance-terraform" {
  datacenters = ["cascadia"]

  type = "batch"

  parameterized {
    meta_required = ["APPLY_WORKSPACE"]
    payload       = "forbidden"
  }

  meta {
    APPLY_WORKSPACE = "prod-home"
  }

  group "terraform-apply" {
    count = 1

    restart {
      attempts = 0
      mode     = "fail"
    }

    ephemeral_disk {
      size    = 500
    }

    task "apply" {
      driver = "docker"

      template {
        destination = "${NOMAD_SECRETS_DIR}/env"
        env = true
        data = <<-EOH
          GIT_REPO_URL = "https://github.com/demophoon/homelab"

          {{ with secret "kv/env/infra/terraform" }}
            {{ range $k, $v := .Data.data }}
              {{ $k }} = "{{ $v }}"
            {{ end }}
          {{ end }}
          TF_CLI_CONFIG_FILE="/secrets/tfc-config"
          GOOGLE_APPLICATION_CREDENTIALS="/secrets/sa.json"

          {{ range service "http.nomad" }}
          NOMAD_ADDR = "https://{{ .Address }}:{{ .Port }}"
          {{ end }}
        EOH
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/tfc-config"
        data = <<-EOH
        {
          "credentials": {
            "app.terraform.io": {
              {{ with secret "kv/env/infra/tfc" }}
              "token": "{{ .Data.data.token }}"
              {{ end }}
            }
          }
        }
        EOH
      }

      template {
        data = <<-EOF
          {{ with secret "gcp/roleset/dns-admin/key" }}
          {{ .Data.private_key_data | base64Decode }}
          {{ end }}
        EOF
        destination = "${NOMAD_SECRETS_DIR}/sa.json"
        perms = "600"
      }

      config {
        #image = "registry.internal.demophoon.com/demophoon/terraform:0.1.0"
        image = "ttl.sh/demophoon/terraform:1h"
        args = [
          "plan",
        ]
      }

      resources {
        cpu = 128
        memory = 128
        memory_max = 512
      }
    }
  }

  vault {
    policies = ["terraform-apply"]
  }
}
