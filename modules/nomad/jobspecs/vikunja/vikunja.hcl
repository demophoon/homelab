variable "image_version" {
  type = string
  default = "0.23"
}

job "vikunja-app" {
  datacenters = ["cascadia"]

  group "vikunja" {
    count = 1

    network {
      port "app" { to = 3456 }
    }

    task "app" {
      driver = "docker"
      config {
        image = "vikunja/vikunja:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/vikunja/db:/data/db",
          "/mnt/nfs/vikunja/files:/data/files",
        ]
      }
      resources {
        cpu = 1024
        memory = 512
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env"
        env = true
        data = <<-EOF
        {{- with secret "kv/apps/vikunja/app" }}
        VIKUNJA_SERVICE_JWTSECRET = "{{ .Data.data.jwt_secret }}"
        {{- end }}

        VIKUNJA_SERVICE_ROOTPATH = "/local/"
        VIKUNJA_SERVICE_PUBLICURL = "https://tasks.brittg.com/"
        VIKUNJA_DATABASE_PATH = "/data/db/vikunja.db"
        VIKUNJA_FILES_BASEPATH = "/data/files"
        VIKUNJA_SERVICE_ENABLEREGISTRATION = "false"
        VIKUNJA_SERVICE_TIMEZONE = "America/Los_Angeles"

        VIKUNJA_LOG_MAIL = "stderr"
        EOF
      }

      template {
        destination = "local/config.yml"
        data = <<-EOF
          auth:
            local:
              enabled: false

            # **Note 2:** The frontend expects to be redirected after authentication by the third party
            # to <frontend-url>/auth/openid/<auth key>. Please make sure to configure the redirect url with your third party
            # auth service accordingly if you're using the default Vikunja frontend.
            # Take a look at the [default config file](https://github.com/go-vikunja/api/blob/main/config.yml.sample) for more information about how to configure openid authentication.
            openid:
              enabled: true
              providers:
                {{- with secret "kv/apps/vikunja/oauth" }}
                - name: "Authentik"
                  # The auth url to send users to if they want to authenticate using OpenID Connect.
                  authurl: https://sso.brittg.com/application/o/vikunja/
                  clientid: "{{ .Data.data.client_id }}"
                  clientsecret: "{{ .Data.data.client_secret }}"
                {{- end }}

          {{- with secret "kv/apps/smtp" }}
          mailer:
            enabled: true
            fromemail: tasks@brittg.com
            authtype: "login"
            host: "{{ .Data.data.host }}"
            port: "{{ .Data.data.port }}"
            username: "{{ .Data.data.username }}"
            password: "{{ .Data.data.password }}"
          {{- end }}
        EOF
      }

      service {
        name = "vikunja"
        port = "app"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.vikunja.rule=host(`tasks.brittg.com`)",
        ]
      }
    }
  }

  vault {
    role = "vikunja"
  }
}

