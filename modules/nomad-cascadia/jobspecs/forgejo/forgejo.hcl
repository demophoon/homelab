variable "image_version" {
  type = string
  default = "14.0.3" # image: code.forgejo.org/forgejo/forgejo
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
           FORGEJO_CUSTOM=/secret/forgejo/
         EOF
         destination = "/local/config.env"
         env = true
      }

      template {
         data = <<EOF
           [mailer]
           ENABLED        = true
           FROM           = forgejo+notifications@brittg.com
           PROTOCOL       = smtps
           {{ with secret "kv/apps/smtp" }}
           SMTP_ADDR      = {{ .Data.data.host }}
           SMTP_PORT      = {{ .Data.data.port }}
           USER           = {{ .Data.data.username }}
           PASSWD         = `{{ .Data.data.password }}`
           {{ end }}

           [openid]
           ENABLE_OPENID_SIGNIN = false
         EOF
         destination = "/secret/forgejo/conf/app.ini"
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

