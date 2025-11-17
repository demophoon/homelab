job "infrastructure-maintenance-vault" {
  datacenters = ["cascadia"]

  type = "sysbatch"

  periodic {
    cron             = "@daily"
    prohibit_overlap = true
  }

  group "vault-unseal" {
    count = 1

    restart {
      attempts = 0
    }

    task "unseal" {
      driver = "docker"

      env {
        VAULT_ADDR = "https://active.vault.service.consul.demophoon.com:8200"
        VAULT_SKIP_VERIFY = "true"
      }

      template {
        destination = "local/unseal.sh"
        perms = 700
        data = <<-EOH
          #!/bin/sh

          if ! $(vault status -address=https://{{ env "attr.unique.network.ip-address" }}:8200 -tls-server-name=vault.service.consul.demophoon.com); then
            encrypted_key=$(vault kv get -field=unseal_key -mount=kv env/infra/vault)
            export key=$(vault write -field=plaintext transit/decrypt/auto-unseal ciphertext="$encrypted_key" | base64 -dw0) > /dev/null
            vault operator unseal -address=https://{{ env "attr.unique.network.ip-address" }}:8200 "$key" > /dev/null
            echo "Vault unsealed successfully."
          else
              echo "Vault is already unsealed."
          fi
        EOH
      }

      config {
        image = "hashicorp/vault:1.20"

        command = "sh"
        args = [
          "-c",
          "${NOMAD_TASK_DIR}/unseal.sh",
        ]
      }

      resources {
        cpu = 100
        memory = 32
        memory_max = 64
      }

      vault {
        role = "unsealer"
      }
      identity {
        name        = "vault_default"
        aud         = ["infrastructure.demophoon.com"]
        file        = true
      }
    }
  }
}
