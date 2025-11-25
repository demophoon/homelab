job "infrastructure-maintenance-terraform" {
  datacenters = ["cascadia"]

  type = "batch"

  constraint {
    attribute = "${meta.region}"
    value     = "cascadia"
  }

  constraint {
    attribute = "${meta.workspace}"
    operator  = "!="
    value     = "${NOMAD_META_APPLY_WORKSPACE}"
  }

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

          NOMAD_ADDR="https://nomad.service.consul.demophoon.com:4646"
          NOMAD_CACERT="/local/ca.crt"

          VAULT_ADDR="https://active.vault.service.consul.demophoon.com:8200"
          VAULT_CACERT="/local/ca.crt"

          CONSUL_HTTP_ADDR="https://consul.service.consul.demophoon.com:8501"
          CONSUL_CACERT="/local/ca.crt"
        EOH
      }

      template {
        destination = "/local/ca.crt"
        data = <<-EOH
        {{- with secret "pki/cert/ca_chain" -}}
        {{ .Data.certificate }}
        {{- end -}}
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
        image = "nexus.internal.demophoon.com/docker-internal/terraform:0.1.1"
        args = [
          "apply",
        ]
      }

      resources {
        cpu = 200
        memory = 256
        memory_max = 1024
      }

      vault {
        role = "terraform-apply"
      }

      identity {
        name        = "vault_default"
        aud         = ["infrastructure.demophoon.com"]
        ttl         = "15m"
      }

    }
  }
}
