job "infrastructure-maintenance-terraform" {
  datacenters = ["cascadia"]

  type = "batch"

  constraint {
    attribute = "${meta.region}"
    value     = "cascadia"
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
          -----BEGIN CERTIFICATE-----
          MIIDbTCCAlWgAwIBAgIUSfFbbeogDEV/7N8W/6Eh5KjIqswwDQYJKoZIhvcNAQEL
          BQAwKDEmMCQGA1UEAxMdY29uc3VsLnNlcnZpY2VzLmRlbW9waG9vbi5jb20wHhcN
          MjIwNzE0MDIzOTQ4WhcNMzIwNzExMDI0MDE4WjAoMSYwJAYDVQQDEx1jb25zdWwu
          c2VydmljZXMuZGVtb3Bob29uLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
          AQoCggEBAOAAqrLGmkBQ0pyfXckOylsUh/5fvuxGLK97bb5GyhsdEtDVuk7Gmt5i
          NGt6Q3gN3OtzseWmfzN6EKa+kCy4QAXXXSUxv8iznOxnwqYyCcUsTX3dlHIlCLgU
          TtI0BnrB55YgPkrXe8Du4DQiHx6aSXioF0gIrRgVPdtQg1+Has2kzLeLumkiI4Zj
          /+FA3t1NWlqkDG9pCfm2AkSsC2Snx/eUMWzuV1kTYkOXN6cmLXF7BId2Y4tbBG0i
          33BTZfY6/MkWkm4GYQainYGG+WW6F+MHmgwx4B3nwpcwqxyk8GF4vjQ7IQlPf2Ku
          Sbb1Nt3deOWehSVeSIaUBFG953d/aJMCAwEAAaOBjjCBizAOBgNVHQ8BAf8EBAMC
          AQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUV1It885u2ER42g6lUF/3JVRh
          wCAwHwYDVR0jBBgwFoAUV1It885u2ER42g6lUF/3JVRhwCAwKAYDVR0RBCEwH4Id
          Y29uc3VsLnNlcnZpY2VzLmRlbW9waG9vbi5jb20wDQYJKoZIhvcNAQELBQADggEB
          AHfs1Z9N1D8LluxMkQZmOX7y01tZ/P1MFSnbkyVERMFD2JfisL3FXSZNUBaL9t8l
          aNC6ZrkKOD8AF5J6i1LciNnmJZT/qkGGNuGI/tLWlxPLyMe5lZbpWpHyvdVBRdjo
          /i8cd3mePMzMlhi2yX6Ht5dOkFi7XupMMw9DlEeOzxv1Rlj2MaW1dXxijJLd3oto
          S2h8TAzKaBVL8yKiiilWZvWG9RHmiG3Rx/83tng5XMDBLpmra8KOFaK/Q0JJEjGL
          J1C5MDqPoeAcvhtRH4tr2YN/MBsxBxF4HIWoQkUhZQ7UNEEuS36zGizqaSWT/Sil
          0uIz3uOy/6H6p0TO0yQbdyQ=
          -----END CERTIFICATE-----
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
        aud         = ["demophoon.com"]
        file        = true
        ttl         = "15m"
      }

    }
  }
}
