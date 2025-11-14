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

    ephemeral_disk {
      migrate = true
      sticky  = true
      size    = 500
    }

    task "clone" {
      driver = "docker"
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      env {
        TF_CLI_CONFIG_FILE = "${NOMAD_SECRETS_DIR}/tfc-config"
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/tfc-config"
        data = <<-EOH
        {
          "credentials": {
            "app.terraform.io": {
              {{ with secret "env/infra/tfc" }}
              "token": "{{ .Data.data.token }}"
              {{ end }}
            }
          }
        }
        EOH
      }

      template {
        destination = "${NOMAD_TASK_DIR}/clone.sh"
        perms = 700
        data = <<-EOH
          apk add --no-cache git
          apk add --no-cache terraform
          git clone https://github.com/demophoon/homelab ${NOMAD_TASK_DIR}/homelab
          cd ${NOMAD_TASK_DIR}/homelab/workspaces/${NOMAD_META_APPLY_WORKSPACE}
          terraform init -upgrade
        EOH
      }

      config {
        image = "alpine:latest"
        command = "sh"
        args = [
          "-c",
          "${NOMAD_TASK_DIR}/clone.sh",
        ]
      }

      resources {
        cpu = 128
        memory = 128
        memory_max = 512
      }
    }

    task "apply" {
      driver = "docker"

      template {
        destination = "${NOMAD_SECRETS_DIR}/env"
        env = true
        data = <<-EOH
          {{ with secret "env/infra/terraform" }}
            {{ range $k, $v := .Data.data }}
              {{ $k }} = "{{ $v }}"
            {{ end }}
          {{ end }}
          TF_CLI_CONFIG_FILE="${NOMAD_SECRETS_DIR}/tfc-config"
          GOOGLE_APPLICATION_CREDENTIALS="${NOMAD_SECRETS_DIR}/sa.json"
        EOH
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/tfc-config"
        data = <<-EOH
        {
          "credentials": {
            "app.terraform.io": {
              {{ with secret "env/infra/tfc" }}
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
        image = "hashicorp/terraform:latest"
        work_dir = "${NOMAD_TASK_DIR}/homelab/workspaces/${NOMAD_META_APPLY_WORKSPACE}"
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
