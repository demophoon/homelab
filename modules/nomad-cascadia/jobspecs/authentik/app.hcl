variable "image_uri" {
  type = string
  default = "ghcr.io/goauthentik/server"
}
variable "image_version" {
  type = string
  default = "2024.12.1"
}

job "authentik-app" {
  datacenters = ["cascadia"]
  region = "global"

  group "app" {
    count = 1
    network {
      port "app" { to = 9000 }
    }
    task "server" {
      driver = "docker"

      config {
        image = "${var.image_uri}:${var.image_version}"
        ports = ["app"]
        command = "server"
        volumes = [
          "/mnt/nfs/authentik/server/media:/media",
          "/mnt/nfs/authentik/server/templates:/templates",
        ]
      }
      resources {
        cpu = 256
        memory = 384
        memory_max = 1024
      }
      template {
        destination = "local/config.env"
        data = <<-EOF
          {{ with secret "kv/apps/authentik/app" }}
          AUTHENTIK_SECRET_KEY="{{ .Data.data.secret_key }}"
          {{ end }}

          {{ with secret "kv/apps/smtp" }}
          AUTHENTIK_EMAIL__HOST="{{ .Data.data.host }}"
          AUTHENTIK_EMAIL__PORT={{ .Data.data.port }}
          AUTHENTIK_EMAIL__USERNAME="{{ .Data.data.username }}"
          AUTHENTIK_EMAIL__PASSWORD="{{ .Data.data.password }}"
          AUTHENTIK_EMAIL__USE_TLS=true
          AUTHENTIK_EMAIL__TIMEOUT=10
          AUTHENTIK_EMAIL__FROM="authentik@brittg.com"
          {{ end }}

          {{ with secret "kv/apps/authentik/s3" }}
          AUTHENTIK_STORAGE__MEDIA__BACKEND=s3
          AUTHENTIK_STORAGE__MEDIA__S3__ENDPOINT="{{ .Data.data.endpoint }}"
          AUTHENTIK_STORAGE__MEDIA__S3__ACCESS_KEY="{{ .Data.data.access_key }}"
          AUTHENTIK_STORAGE__MEDIA__S3__SECRET_KEY="{{ .Data.data.secret_key }}"
          AUTHENTIK_STORAGE__MEDIA__S3__BUCKET_NAME="{{ .Data.data.bucket_name }}"
          {{ end }}

          {{- range service "authentik-postgres" }}
          AUTHENTIK_POSTGRESQL__HOST="{{ .Address }}"
          AUTHENTIK_POSTGRESQL__PORT="{{ .Port }}"
          AUTHENTIK_POSTGRESQL__CONN_MAX_AGE=0
          {{ with secret "kv/apps/authentik/postgresql" }}
          AUTHENTIK_POSTGRESQL__USER="{{ .Data.data.username }}"
          AUTHENTIK_POSTGRESQL__NAME="{{ .Data.data.database }}"
          AUTHENTIK_POSTGRESQL__PASSWORD="{{ .Data.data.password }}"
          {{ end }}
          {{ end }}

          {{- range service "authentik-redis" }}
          AUTHENTIK_REDIS__HOST="{{ .Address }}"
          AUTHENTIK_REDIS__PORT="{{ .Port }}"
          {{ end }}
        EOF
        env = true
      }
      service {
        name = "authentik-server"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.authentik-server.rule=host(`sso.brittg.com`)",
        ]
      }

      vault {
        role = "authentik"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }

  group "proxy" {
    count = 1
    network {
      port "app" { static = 9000 }
    }
    task "proxy" {
      driver = "docker"

      config {
        image = "ghcr.io/goauthentik/proxy"
        ports = ["app"]
      }
      resources {
        cpu = 256
        memory = 256
        memory_max = 512
      }
      template {
        destination = "local/config.env"
        data = <<-EOF
          AUTHENTIK_HOST="https://sso.brittg.com"
          AUTHENTIK_INSECURE="false"
          {{ with secret "kv/apps/authentik/worker" }}
          AUTHENTIK_TOKEN="{{ .Data.data.token }}"
          {{ end }}
        EOF
        env = true
      }
      service {
        name = "authentik-proxy"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.authentik-proxy.rule=hostregexp(`^.+\\.brittg.com$`) && PathPrefix(`/outpost.goauthentik.io/`)",

          "traefik.http.middlewares.authentik.forwardauth.address=http://authentik-proxy.service.consul.demophoon.com:9000/outpost.goauthentik.io/auth/traefik",
          "traefik.http.middlewares.authentik.forwardauth.trustForwardHeader=true",
          "traefik.http.middlewares.authentik.forwardauth.authResponseHeaders=X-authentik-username,X-authentik-groups,X-authentik-entitlements,X-authentik-email,X-authentik-name,X-authentik-uid,X-authentik-jwt,X-authentik-meta-jwks,X-authentik-meta-outpost,X-authentik-meta-provider,X-authentik-meta-app,X-authentik-meta-version",
        ]
      }

      vault {
        role = "authentik"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }

  group "workers" {
    count = 1
    task "worker" {
      driver = "docker"

      config {
        image = "${var.image_uri}:${var.image_version}"
        volumes = [
          "/mnt/nfs/authentik/server/media:/media",
          "/mnt/nfs/authentik/server/certs:/certs",
          "/mnt/nfs/authentik/server/templates:/templates",
        ]
        command = "worker"
      }
      resources {
        cpu = 1024
        memory = 512
        memory_max = 2048
      }
      template {
        destination = "local/config.env"
        env = true
        data = <<-EOF
          {{ with secret "kv/apps/authentik/app" }}
          AUTHENTIK_SECRET_KEY="{{ .Data.data.secret_key }}"
          {{ end }}

          {{ with secret "kv/apps/smtp" }}
          AUTHENTIK_EMAIL__HOST="{{ .Data.data.host }}"
          AUTHENTIK_EMAIL__PORT={{ .Data.data.port }}
          AUTHENTIK_EMAIL__USERNAME="{{ .Data.data.username }}"
          AUTHENTIK_EMAIL__PASSWORD="{{ .Data.data.password }}"
          AUTHENTIK_EMAIL__USE_TLS=true
          AUTHENTIK_EMAIL__TIMEOUT=10
          AUTHENTIK_EMAIL__FROM="authentik@brittg.com"
          {{ end }}

          {{ with secret "kv/apps/authentik/s3" }}
          AUTHENTIK_STORAGE__MEDIA__BACKEND=s3
          AUTHENTIK_STORAGE__MEDIA__S3__ENDPOINT="{{ .Data.data.endpoint }}"
          AUTHENTIK_STORAGE__MEDIA__S3__ACCESS_KEY="{{ .Data.data.access_key }}"
          AUTHENTIK_STORAGE__MEDIA__S3__SECRET_KEY="{{ .Data.data.secret_key }}"
          AUTHENTIK_STORAGE__MEDIA__S3__BUCKET_NAME="{{ .Data.data.bucket_name }}"
          {{ end }}

          {{- range service "authentik-postgres" }}
          AUTHENTIK_POSTGRESQL__HOST="{{ .Address }}"
          AUTHENTIK_POSTGRESQL__PORT="{{ .Port }}"
          AUTHENTIK_POSTGRESQL__CONN_MAX_AGE=0
          {{ with secret "kv/apps/authentik/postgresql" }}
          AUTHENTIK_POSTGRESQL__USER="{{ .Data.data.username }}"
          AUTHENTIK_POSTGRESQL__NAME="{{ .Data.data.database }}"
          AUTHENTIK_POSTGRESQL__PASSWORD="{{ .Data.data.password }}"
          {{ end }}
          {{ end }}

          {{- range service "authentik-redis" }}
          AUTHENTIK_REDIS__HOST="{{ .Address }}"
          AUTHENTIK_REDIS__PORT="{{ .Port }}"
          {{ end }}
        EOF
      }

      vault {
        role = "authentik"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}

