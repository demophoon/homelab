#  pds:
#    container_name: pds
#    image: ghcr.io/bluesky-social/pds:0.4
#    network_mode: host
#    restart: unless-stopped
#    volumes:
#      - type: bind
#        source: /pds
#        target: /pds
#    env_file:
#      - /pds/pds.env
variable "image_version" {
  type = string
  default = "0.4" # image: ghcr.io/bluesky-social/pds
}

job "bluesky-pds" {
  datacenters = ["cascadia"]

  group "pds" {
    count = 1

    network {
      port "app" { to = 3000 }
    }

    task "bluesky-pds" {
      driver = "docker"

      config {
        image = "ghcr.io/bluesky-social/pds:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/bluesky/pds:/pds",
        ]
      }
      resources {
        cpu = 512
        memory = 1024
        memory_max = 2048
      }

      template {
        destination = "local/config.env"
        data = <<EOF
          PDS_HOSTNAME="brittg.com"
          {{ with secret "kv/apps/bluesky" }}
          PDS_JWT_SECRET={{ .Data.data.jwt_secret }}
          PDS_ADMIN_PASSWORD={{ .Data.data.admin_password }}
          PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX={{ .Data.data.private_key_hex }}
          {{ end }}
          PDS_DATA_DIRECTORY=/pds
          PDS_BLOBSTORE_DISK_LOCATION=/pds/blocks
          PDS_BLOB_UPLOAD_LIMIT=52428800

          PDS_DID_PLC_URL="https://plc.directory"
          PDS_BSKY_APP_VIEW_URL="https://api.bsky.app"
          PDS_BSKY_APP_VIEW_DID="did:web:api.bsky.app"
          PDS_REPORT_SERVICE_URL="https://mod.bsky.app"
          PDS_REPORT_SERVICE_DID="did:plc:ar7c4by46qjdydhdevvrndac"
          PDS_CRAWLERS="https://bsky.network"

          LOG_ENABLED=true

          {{ with secret "kv/apps/smtp" }}
          PDS_EMAIL_SMTP_URL={{ sprig_urlJoin (sprig_dict
                "scheme" "smtps"
                "host" ((sprig_list .Data.data.host .Data.data.port) | sprig_join ":")
                "userinfo" (((sprig_list .Data.data.username .Data.data.password) | sprig_join ":") | sprig_replace "/" "%2F")
            )
          }}
          {{ end }}
          PDS_EMAIL_FROM_ADDRESS=bluesky@brittg.com
        EOF
        env = true
      }

      service {
        name = "${TASK}"
        port = "app"
        tags = [
          # Enable Traefik
          "traefik.enable=true",

          # AT Protocol PDS
          "traefik.http.routers.bluesky-pds.rule=(host(`brittg.com`) && pathprefix(`/xrpc`)) || host(`demophoon.brittg.com`)",
        ]
      }


      vault {
        role = "bluesky"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        file        = true
      }
    }
  }
}
