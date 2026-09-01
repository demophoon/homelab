variable "image_version" {
  default = "v1.27.0" # image: ghcr.io/techarohq/anubis
}

job "anubis" {
  datacenters = ["cascadia"]

  group "anubis-middleware" {
    count = 1

    network {
      port "app" {
        to = 8080
        static = 16758
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "ghcr.io/techarohq/anubis:${var.image_version}"
        ports = ["app"]
      }

      resources {
        cpu = 100
        memory = 128
      }

      template {
        data = <<-EOF
          BIND=:8080
          DIFFICULTY=4
          METRICS_BIND=:9090
          SERVE_ROBOTS_TXT=true
          POLICY_FNAME=/local/botPolicy.yaml

          USE_SIMPLIFIED_EXPLANATION=true

          TARGET=" "
          REDIRECT_DOMAINS=brittg.com,*.brittg.com,*.internal.demophoon.com
          PUBLIC_URL=https://speedbump.brittg.com
          COOKIE_DYNAMIC_DOMAIN=true

          {{- with secret "kv/data/apps/anubis" }}
          ED25519_PRIVATE_KEY_HEX={{ .Data.data.ed25519_private_key_hex }}
          {{- end }}
        EOF
        destination = "local/env"
        env = true
      }

      template {
        data = <<-EOF
          bots:
            - import: (data)/meta/default-config.yaml
            - name: cloudflare-workers
              headers_regex:
                CF-Worker: .*
              action: DENY
            - name: well-known
              path_regex: ^/.well-known/.*$
              action: ALLOW
            - name: favicon
              path_regex: ^/favicon.ico$
              action: ALLOW
            - name: robots-txt
              path_regex: ^/robots.txt$
              action: ALLOW
        EOF
        destination = "local/botPolicy.yaml"
      }

      service {
        name = "anubis"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.anubis.rule=host(`speedbump.brittg.com`)",
          "traefik.http.routers.anubis.entrypoints=secure",
          "traefik.http.middlewares.anubis.forwardauth.address=http://anubis.service.consul.demophoon.com:16758/.within.website/x/cmd/anubis/api/check",
        ]
      }

      vault {
        role = "anubis"
      }
      identity {
        name = "vault_default"
        aud  = ["demophoon.com"]
        ttl  = "1h"
      }

    }
  }
}
