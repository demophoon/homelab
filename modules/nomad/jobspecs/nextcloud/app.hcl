variable "image_version" {
  type = string
  default = "27.1.3"
}

job "nextcloud-app" {
  datacenters = ["cascadia"]

    # Application
  group "app" {
    count = 1

    volume "nextcloud" {
      type      = "host"
      source    = "nextcloud_app"
    }

    network {
      port "app" { to = 80 }
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
      }
      volume_mount {
        volume      = "nextcloud"
        destination = "/var/www/html"
      }

      template {
         data = <<EOF
{{- range service "nextcloud-db" }}
MYSQL_HOST={{ .Address }}
{{ end }}
{{ with secret "kv/apps/nextcloud/mysql" }}
MYSQL_DATABASE="{{ .Data.data.database }}"
MYSQL_USER="{{ .Data.data.username }}"
MYSQL_PASSWORD="{{ .Data.data.password }}"
{{ end }}

{{- range service "nextcloud-redis" }}
REDIS_HOST={{ .Address }}
REDIS_HOST_PORT={{ .Port }}
{{ end }}

IMAGINARY_HOST=https://nextcloud-imaginary.internal.demophoon.com
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
         destination = "config.env"
         env = true
      }

      template {
        data = <<EOF
<?php
$CONFIG = array (
  'config_is_read_only' => true,
  'log_type' => 'file',
  'logfile' => 'nextcloud.log',
  'loglevel' => 3,
  'logdateformat' => 'F d, Y H:i:s',
  'installed' => true,
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => 
  array (
{{- range service "nextcloud-redis" }}
    'host' => '{{ .Address }}',
    'port' => {{ .Port }},
{{ end }}
  ),
  'trusted_proxies' => 
  array (
  ),
{{- with secret "kv/apps/smtp" }}
  'mail_smtpmode' => 'smtp',
  'mail_smtphost' => '{{ .Data.data.host }}',
  'mail_smtpport' => '{{ .Data.data.port }}',
  'mail_smtpsecure' => 'ssl',
  'mail_smtpauth' => true,
  'mail_smtpauthtype' => 'LOGIN',
  'mail_smtpname' => '{{ .Data.data.username }}',
  'mail_from_address' => 'nextcloud-notifications',
  'mail_domain' => 'brittg.com',
  'mail_smtppassword' => '{{ .Data.data.password }}',
{{- end}}
  'upgrade.disable-web' => true,
{{- with secret "kv/apps/nextcloud/app" }}
  'instanceid' => '{{ .Data.data.instanceid }}',
  'passwordsalt' => '{{ .Data.data.passwordsalt }}',
  'secret' => '{{ .Data.data.secret }}',
{{- end}}
  'trusted_domains' =>
  array (
    0 => 'cloud.brittg.com',
  ),

  'dbtype' => 'mysql',
{{- range service "nextcloud-db" }}
  'dbhost' => '{{ .Address }}',
{{ end }}

{{ with secret "kv/apps/nextcloud/mysql" }}
  'dbname' => '{{ .Data.data.database }}',
  'dbuser' => '{{ .Data.data.username }}',
  'dbpass' => '{{ .Data.data.password}}',
  'dbpassword' => '{{ .Data.data.password }}',
{{ end }}

  'datadirectory' => '/var/www/html/data',
  'version' => '31.0.5.1',
  'overwrite.cli.url' => 'https://cloud.brittg.com',
  'overwriteprotocol' => 'https',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'maintenance' => false,
  'allow_local_remote_servers' => true,
);
EOF
         destination = "local/config.php"
      }

      resources {
        cpu = 2048
        memory = 2048
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

          "traefik.http.routers.nextcloud.rule=Host(`cloud.brittg.com`) || Host(`cloud.services.demophoon.com`) || Host(`cloud.cascadia.demophoon.com`)",
          "traefik.http.routers.nextcloud.middlewares=nextcloud-chain",
        ]
      }
    }
  }

  vault {
    role = "nextcloud"
  }
}
