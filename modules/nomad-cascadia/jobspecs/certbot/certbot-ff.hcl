job "certbot-flawedfauna" {
  datacenters = ["cascadia"]
  node_pool = "ingress"

  type = "batch"

  periodic {
    cron             = "0 0 0 1 * * *"
    prohibit_overlap = true
  }

  group "certbot" {
    count = 1

    restart {
      attempts = 0
    }

    ephemeral_disk {
      migrate = true
      sticky  = true
      size    = 250
    }

    task "certbot" {
      driver = "docker"

      config {
        image = "certbot/dns-google:latest"
        args = [
          "certonly",
          "-v",

          "--non-interactive",

          "--config", "/local/config.ini",
          "--deploy-hook", "/local/deploy.sh",

          "--dns-google",
          "--dns-google-credentials", "/secrets/sa.json",
          "--dns-google-propagation-seconds", "120",

          "--domain", "flawedfauna.com",
          "--domain", "*.flawedfauna.com",
        ]
      }
      resources {
        cpu = 256
        memory = 128
      }

      template {
        data = <<EOF
email = letsencrypt-flawedfauna@brittg.com
agree-tos = true
EOF
        destination = "local/config.ini"
      }

      template {
        data = <<EOF
#!/bin/sh
cat /etc/letsencrypt/live/flawedfauna.com/privkey.pem | base64 -w 0 > /alloc/data/privkey.pem.b64
cat /etc/letsencrypt/live/flawedfauna.com/fullchain.pem | base64 -w 0 > /alloc/data/fullchain.pem.b64
EOF
        destination = "local/deploy.sh"
        perms = "755"
      }

      template {
        data = <<EOF
{{ with secret "gcp/roleset/dns-admin/key" }}
{{ .Data.private_key_data | base64Decode }}
{{ end }}
EOF
        destination = "secrets/sa.json"
        perms = "600"
      }
      vault {
        role = "certbot"
      }
      identity {
        name        = "vault_default"
        aud         = ["infrastructure.demophoon.com"]
        ttl         = "15m"
      }
    }

    task "post-process" {
      driver = "docker"

      lifecycle {
        hook = "poststop"
      }

      env {
        VAULT_ADDR = "https://active.vault.service.consul.demophoon.com:8200"
        VAULT_SKIP_VERIFY = "true"
      }

      config {
        image = "hashicorp/vault:latest"
        args = [
          "kv", "put",
          "-mount", "kv",
          "traefik/certs/flawedfauna-com",
          "key=@/alloc/data/privkey.pem.b64",
          "cert=@/alloc/data/fullchain.pem.b64",
        ]
      }
      resources {
        cpu = 256
        memory = 128
      }

      vault {
        role = "certbot"
      }
      identity {
        name        = "vault_default"
        aud         = ["infrastructure.demophoon.com"]
        ttl         = "15m"
      }
    }
  }
}
