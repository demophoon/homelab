variable "image_version" {
  type = string
  default = "27.1.3"
}

job "nextcloud-app" {
  datacenters = ["cascadia"]

    # Application
  group "app" {
    count = 1

    network {
      port "app" { to = 80 }
    }

    task "restore-config" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image = "servercontainers/rsync:latest"
        command = "sh"
        args = [
          "-c",
          "rsync --info=progress2 --exclude '/nfs/data/' -a /nfs/ /local-server",
        ]
        volumes = [
          "/mnt/nfs/nextcloud-global:/nfs",
          "/opt/nextcloud:/local-server",
        ]
      }
    }

    task "backup-config" {
      lifecycle {
        hook = "poststop"
        sidecar = false
      }

      driver = "docker"

      config {
        image = "servercontainers/rsync:latest"
        command = "sh"
        args = [
          "-c",
          "rsync --info=progress2 --exclude '/local-server/data/' -a /local-server/ /nfs",
        ]
        volumes = [
          "/mnt/nfs/nextcloud-global:/nfs",
          "/opt/nextcloud:/local-server",
        ]
      }
    }

    task "nextcloud" {
      driver = "docker"

      action "files-scan" {
        command = "/var/www/html/occ"
        args = [
          "files:scan",
          "--all",
        ]
      }

      config {
        image = "nextcloud:${var.image_version}"
        image_pull_timeout = "15m"
        ports = ["app"]
        volumes = [
          "/opt/nextcloud:/var/www/html",
          "/mnt/nfs/nextcloud-global/data:/var/www/html/data",
        ]
      }

      template {
         data = <<EOF
{{ with secret "kv/apps/nextcloud/app" }}
NEXTCLOUD_ADMIN_USER="{{ .Data.data.username }}"
NEXTCLOUD_ADMIN_PASSWORD="{{ .Data.data.password }}"
{{ end }}

POSTGRES_DB="nextcloud"
POSTGRES_HOST="192.168.1.163:15432"
POSTGRES_PORT="15432"
{{ with secret "postgres/static-creds/nextcloud-admin" }}
POSTGRES_USER="{{ .Data.username }}"
POSTGRES_PASSWORD="{{ .Data.password }}"
{{ end }}

{{- range service "nextcloud-redis" }}
REDIS_HOST={{ .Address }}
REDIS_HOST_PORT={{ .Port }}
{{ end }}

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
         EOF
         destination = "/local/config.env"
         env = true
      }

      resources {
        cpu = 500
        memory = 512
        memory_max = 3072
      }

      service {
        name = "nextcloud-internal"
        port = "app"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.nextcloud-internal.rule=Host(`cloud.internal.demophoon.com`)",
        ]
      }

      service {
        name = "${TASK}"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.middlewares.nextcloud-wellknown.replacepathregex.regex=^\\.well-known/(card|cal)dav(.*)",
          "traefik.http.middlewares.nextcloud-wellknown.replacepathregex.replacement=/nextcloud/remote.php/dav$${1}",

          "traefik.http.middlewares.nextcloud-webfinger.replacepathregex.regex=^\\.well-known/webfinger",
          "traefik.http.middlewares.nextcloud-webfinger.replacepathregex.replacement=/nextcloud/index.php/.well-known/webfinger",

          "traefik.http.middlewares.nextcloud-nodeinfo.replacepathregex.regex=^\\.well-known/nodeinfo",
          "traefik.http.middlewares.nextcloud-nodeinfo.replacepathregex.replacement=/nextcloud/index.php/.well-known/nodeinfo",

          "traefik.http.middlewares.nextcloud-redirect.redirectregex.regex=^https?://cloud\\..*\\.demophoon\\.com/(.*)",
          "traefik.http.middlewares.nextcloud-redirect.redirectregex.replacement=https://cloud.brittg.com/$${1}",

          "traefik.http.middlewares.nextcloud-chain.chain.middlewares=nextcloud-webfinger,nextcloud-nodeinfo,nextcloud-wellknown,nextcloud-redirect",

          "traefik.http.routers.nextcloud.rule=Host(`cloud.brittg.com`) || Host(`cloud.services.demophoon.com`)",
          "traefik.http.routers.nextcloud.middlewares=nextcloud-chain",
        ]
      }

      vault {
        role = "nextcloud"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        file        = true
      }
    }
  }
}
