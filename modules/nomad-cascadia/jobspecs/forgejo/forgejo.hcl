variable "image_version" {
  type = string
  default = "15.0.7" # image: codeberg.org/forgejo/forgejo
}

job "forgejo" {
  datacenters = ["cascadia"]

  group "app" {
    count = 1

    network {
      port "app" { to = 3000 }
      port "ssh" { to = 22 }
    }

    task "forgejo" {
      driver = "docker"

      vault {
        role = "forgejo"
      }

      identity {
        name = "vault_default"
        ttl  = "15m"
        aud  = ["demophoon.com"]
      }

      config {
        image = "codeberg.org/forgejo/forgejo:${var.image_version}"
        image_pull_timeout = "15m"
        ports = ["app", "ssh"]
        volumes = [
          "/mnt/nfs/forgejo/data:/data",
          "/etc/localtime:/etc/localtime:ro",
        ]
      }

      template {
         data = <<EOF
           USER_UID=1000
           USER_GID=1000
         EOF
         destination = "/local/config.env"
         env = true
      }

      template {
         data = <<EOF
           FORGEJO__database__DB_TYPE = postgres
           FORGEJO__database__HOST = postgres-nas.service.consul.demophoon.com:5432
           {{ with secret "kv/apps/forgejo/database" }}
           FORGEJO__database__NAME = {{ .Data.data.database }}
           FORGEJO__database__USER = {{ .Data.data.username }}
           FORGEJO__database__PASSWD = {{ .Data.data.password }}
           {{ end }}

           FORGEJO__service__DISABLE_REGISTRATION = true
           FORGEJO__service__NO_REPLY_ADDRESS = brittg.com
           FORGEJO__service__ENABLE_NOTIFY_MAIL=true

           FORGEJO__mailer__ENABLED        = true
           FORGEJO__mailer__FROM           = forgejo+notifications@brittg.com
           FORGEJO__mailer__PROTOCOL       = smtp+starttls
           {{ with secret "kv/apps/smtp" }}
           FORGEJO__mailer__SMTP_ADDR      = {{ .Data.data.host }}
           FORGEJO__mailer__SMTP_PORT      = {{ .Data.data.port }}
           FORGEJO__mailer__USER           = {{ .Data.data.username }}
           FORGEJO__mailer__PASSWD         = {{ .Data.data.password }}
           {{ end }}

           FORGEJO__openid__ENABLE_OPENID_SIGNIN = false

           FORGEJO__repository__ENABLE_PUSH_CREATE_USER = true
           FORGEJO__repository__ENABLE_PUSH_CREATE_ORG = true
         EOF
         env = true
         destination = "/secret/config.env"
      }

      resources {
        cpu = 500
        memory = 512
        memory_max = 2048
      }

      service {
        name = "forgejo"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.forgejo-app.rule=Host(`git.brittg.com`)",
        ]
      }

      service {
        name = "forgejo-ssh"
        port = "ssh"
        tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.forgejo-ssh.rule=HostSNI(`*`)",
          "traefik.tcp.routers.forgejo-ssh.entrypoints=ssh",
        ]
      }

    }
  }
}

