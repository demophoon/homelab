variable "image_version" {
  type = string
  default = "v3.1"
}
variable "region" {
  type = string
}

job "traefik-do" {
  datacenters = ["digitalocean"]
  region = "${var.region}"
  priority = 100

  type = "system"

  group "web" {
    count = 1
    network {
      port "http"      { static = 80 }
      port "https"     { static = 443 }
      port "ssh"       { static = 2222 }

      port "valheim"  { static = 2456 }
      port "valheim2" { static = 2457 }
      port "valheim3" { static = 2458 }

      port "synapse" { static = 8448 }

      port "factorio" { static = 34197 }
    }

    task "traefik" {
      driver = "docker"

      restart {
        delay = "30s"
        interval = "5m"
        mode = "delay"
      }

      config {
        image = "traefik:${var.image_version}"
        args = [
          "--configFile", "/local/traefik.yaml"
        ]
        labels { group = "http" }
        network_mode = "host"
        ports = [
          "http",
          "https",
          "ssh",
          "valheim",
          "valheim2",
          "valheim3",
          "synapse",
          "factorio",
        ]
      }
      resources {
        cpu = 256
        memory = 128
        memory_max = 512
      }
      service {
        name = "traefik"
        port = "http"
      }
      service {
        name = "traefik-https"
        port = "https"
      }
      service {
        name = "traefik-ssh"
        port = "ssh"
      }
      service {
        name = "traefik-valheim"
        port = "valheim"
      }
      service {
        name = "traefik-valheim2"
        port = "valheim2"
      }
      service {
        name = "traefik-valheim3"
        port = "valheim3"
      }

      service {
        name = "traefik-synapse"
        port = "synapse"
      }

      service {
        name = "traefik-factorio"
        port = "factorio"
      }

      # Configuration
      template {
        data = <<-EOF
entryPoints:
  traefik:
    address: ':8081'
  insecure:
    address: ':80'
    http:
      redirections:
        entryPoint:
          to: "secure"
          scheme: "https"
  secure:
    address: ':443'
    forwardedHeaders:
      trustedIPs:
        - '192.168.1.0/24'
        - '100.64.0.0/10'
    http:
      tls: {}

  ssh:
    address: ':2222'

  valheim:
    address: ':2456/udp'
  valheim2:
    address: ':2457/udp'
  valheim3:
    address: ':2458/udp'

  empyrion0:
    address: ':30000/udp'
  empyrion1:
    address: ':30001/udp'
  empyrion2:
    address: ':30002/udp'
  empyrion3:
    address: ':30003/udp'
  empyrion4:
    address: ':30004/udp'

  factorio:
    address: ':34197/udp'

  synapse:
    address: ':8448'

providers:
  providersThrottleDuration: 2s
  file:
    watch: true
    directory: '/local/config'
  consulCatalog:
    watch: true
    endpoint:
      address: 'http://{{{ env "node.unique.network.ip-address" }}}:8500'
    defaultRule: "Host(`{{ normalize .Name }}.services.demophoon.com`)"
    exposedByDefault: false
    constraints: "!Tag(`internal=true`)"

experimental:
  otlpLogs: true

log:
  level: DEBUG
{{{- range service "otel-http" }}}
  otlp:
    http:
      endpoint: 'http://{{{- .Address }}}:{{{- .Port }}}/v1/logs'
{{{- end }}}

accesslogs:
{{{- range service "otel-http" }}}
  otlp:
    http:
      endpoint: 'http://{{{- .Address }}}:{{{- .Port }}}/v1/logs'
{{{- end }}}

metrics:
  prometheus:
    entryPoint: internal
{{{- range service "otel-http" }}}
  otlp:
    addEntryPointsLabels: true
    addRoutersLabels: true
    addServicesLabels: true
    http:
      endpoint: 'http://{{{- .Address }}}:{{{- .Port }}}/v1/metrics'
{{{- end }}}

{{{- range service "otel-http" }}}
tracing:
  otlp:
    http:
      endpoint: 'http://{{{- .Address }}}:{{{- .Port }}}/v1/traces'
{{{- end }}}
        EOF
        destination = "local/traefik.yaml"
        left_delimiter = "{{{"
        right_delimiter = "}}}"
      }

      template {
        data = <<-EOF
          middlewares:
            tailscaleOnly:
              ipAllowList:
                sourcerange:
                  - 127.0.0.1
                  - 100.64.0.0/10
        EOF
        destination = "local/http-routers.yaml"
      }

      template {
        data = <<-EOF
          tls:
            stores:
              default:
                defaultCertificate:
                  certFile: "/secrets/certs/cert.pem"
                  keyFile: "/secrets/certs/key.pem"
            certificates:
              - certFile: "/secrets/certs/cert.pem"
                keyFile: "/secrets/certs/key.pem"
                stores:
                  - "default"
        EOF
        destination = "local/config/tls.yaml"
      }

      template {
        data = <<-EOF
          {{ with secret "kv/data/traefik/certs/brittg-com" }}
          {{ .Data.data.cert | base64Decode }}
          {{ end }}
        EOF
        destination = "secrets/certs/cert.pem"
        perms = "600"

      }
      template {
        data = <<-EOF
          {{ with secret "kv/data/traefik/certs/brittg-com" }}
          {{ .Data.data.key | base64Decode }}
          {{ end }}
        EOF
        destination = "secrets/certs/key.pem"
        perms = "600"
      }
    }
  }

  vault {
    role = "traefik"
  }
}
