job "registry-cache" {
  datacenters = ["dc1", "cascadia"]
  priority = 80

  type = "system"

  group "main" {
    count = 1

    volume "cache-volume" {
      type            = "csi"
      source          = "juicefs-volume"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    network {
      port "registry" {
        to = 5000
      }
    }

    task "registry" {
      driver = "docker"

      config {
        image = "registry:2"
        image_pull_timeout = "15m"
        ports = ["registry"]
        #volumes = [
        #  "/opt/registry:/var/lib/registry"
        #]
      }

      volume_mount {
        volume = "cache-volume"
        destination = "/var/lib/registry"
      }

      env {
        REGISTRY_PROXY_REMOTEURL = "https://registry-1.docker.io"
        REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/var/lib/registry"
        REGISTRY_HTTP_TLS_CERTIFICATE = "${NOMAD_SECRETS_DIR}/cert.crt"
        REGISTRY_HTTP_TLS_KEY = "${NOMAD_SECRETS_DIR}/priv.key"
      }

      template {
        data = <<-EOF
        {{ with secret "kv/apps/dockerhub" }}
        REGISTRY_PROXY_USERNAME="{{ .Data.data.username }}"
        REGISTRY_PROXY_PASSWORD="{{ .Data.data.password }}"
        {{ end }}
        EOF
        destination = "${NOMAD_SECRETS_DIR}/env"
        env = true
      }

      template {
        data = <<-EOF
        {{ with secret "pki/issue/backplane" "common_name=registry-cache.service.consul.demophoon.com" }}
        {{- .Data.private_key -}}
        {{ end }}
        EOF
        destination = "${NOMAD_SECRETS_DIR}/priv.key"
      }

      template {
        data = <<-EOF
        {{ with secret "pki/issue/backplane" "common_name=registry-cache.service.consul.demophoon.com" }}
        {{- .Data.certificate -}}
        {{ end }}
        EOF
        destination = "${NOMAD_SECRETS_DIR}/cert.crt"
      }

      resources {
        cpu = 100
        memory = 128
      }
      service {
        name = "registry-cache"
        port = "registry"
        tags = [
          "traefik.enable=true",
          "traefik.tcp.routers.registry-cache.rule=HostSNI(`registry-cache.service.consul.demophoon.com`)",
          "traefik.tcp.routers.registry-cache.tls.passthrough=true",
        ]
        check {
          type        = "tcp"
          port        = "registry"
          interval    = "10s"
          timeout     = "3s"
        }
      }
    }
  }

  vault {
    policies = ["registry-cache"]
  }
}
