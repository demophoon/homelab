variable "image_version" {
  type = string
  default = "32.0.5" # image: nextcloud
}

job "nextcloud-app" {
  datacenters = ["cascadia"]
  node_pool = "nas"

    # Application
  group "app" {
    count = 1

    network {
      port "app" { to = 80 }
    }

    task "nextcloud" {
      driver = "docker"

      action "maintenance-mode-on" {
        command = "/var/www/html/occ"
        args = [
          "maintenance:mode",
          "--on",
        ]
      }

      action "maintenance-mode-off" {
        command = "/var/www/html/occ"
        args = [
          "maintenance:mode",
          "--off",
        ]
      }

      action "maintenance-window-set" {
        command = "/var/www/html/occ"
        args = [
          "config:system:set",
          "maintenance_window_start",
          "--value", "1",
          "--type", "integer",
        ]
      }

      action "files-scan" {
        command = "/var/www/html/occ"
        args = [
          "files:scan",
          "--all",
        ]
      }

      action "add-missing-indicies" {
        command = "/var/www/html/occ"
        args = [
          "db:add-missing-indices",
        ]
      }

      action "mimetype-migrations" {
        command = "/var/www/html/occ"
        args = [
          "maintenance:repair",
          "--include-expensive",
        ]
      }

      config {
        image = "nextcloud:${var.image_version}"
        image_pull_timeout = "15m"
        ports = ["app"]
        volumes = [
          "/mnt/dank0/andromeda/nextcloud-global/html:/var/www/html",
        ]
      }

      template {
        data = <<EOF
          {{ with secret "kv/apps/nextcloud/app" }}
          NEXTCLOUD_ADMIN_USER="{{ .Data.data.username }}"
          NEXTCLOUD_ADMIN_PASSWORD="{{ .Data.data.password }}"
          {{ end }}

          {{- range service "postgres-nas" }}
          POSTGRES_HOST="{{ .Address }}:{{ .Port }}"
          {{ end }}

          {{ with secret "kv/apps/nextcloud/postgres" }}
          POSTGRES_DB="{{ .Data.data.database }}"
          POSTGRES_USER="{{ .Data.data.username }}"
          POSTGRES_PASSWORD="{{ .Data.data.password }}"
          {{ end }}

          {{- range service "nextcloud-redis" }}
          REDIS_HOST={{ .Address }}
          REDIS_HOST_PORT={{ .Port }}
          {{ end }}

          NEXTCLOUD_TRUSTED_DOMAINS="cloud.brittg.com"
          TRUSTED_PROXIES="{{- range service "traefik" }}{{ .Address }} {{ end }}"

          {{ with secret "kv/apps/smtp" }}
          SMTP_HOST="{{ .Data.data.host }}"
          SMTP_PORT={{ .Data.data.port }}
          SMTP_SECURE="ssl"
          SMTP_NAME="{{ .Data.data.username }}"
          SMTP_PASSWORD="{{ .Data.data.password }}"
          {{ end }}

          MAIL_FROM_ADDRESS="nextcloud-notifications"
          MAIL_DOMAIN="brittg.com"

          OVERWRITEPROTOCOL="https"
          ALLOW_LOCAL_REMOTE_SERVERS="true"
        EOF
        destination = "/secrets/config.env"
        env = true
      }

      resources {
        cpu = 500
        memory = 512
        memory_max = 3072
      }

      service {
        name = "nextcloud-app"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.middlewares.nextcloud-wellknown.replacepathregex.regex=^\\.well-known/(card|cal)dav(.*)",
          "traefik.http.middlewares.nextcloud-wellknown.replacepathregex.replacement=/nextcloud/remote.php/dav$${1}",

          "traefik.http.middlewares.nextcloud-webfinger.replacepathregex.regex=^\\.well-known/webfinger",
          "traefik.http.middlewares.nextcloud-webfinger.replacepathregex.replacement=/nextcloud/index.php/.well-known/webfinger",

          "traefik.http.middlewares.nextcloud-nodeinfo.replacepathregex.regex=^\\.well-known/nodeinfo",
          "traefik.http.middlewares.nextcloud-nodeinfo.replacepathregex.replacement=/nextcloud/index.php/.well-known/nodeinfo",

          "traefik.http.middlewares.nextcloud-chain.chain.middlewares=nextcloud-webfinger,nextcloud-nodeinfo,nextcloud-wellknown",

          "traefik.http.routers.nextcloud.rule=Host(`cloud.brittg.com`)",
          "traefik.http.routers.nextcloud.middlewares=nextcloud-chain",
        ]
      }

      vault {
        role = "nextcloud"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
