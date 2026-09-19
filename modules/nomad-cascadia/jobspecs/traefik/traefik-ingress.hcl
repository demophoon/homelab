variable "image_version" {
  type = string
  default = "v3.7.13" # image: traefik
}

job "traefik-ingress" {
  datacenters = ["cascadia", "vultr"]
  region = "global"
  priority = 100
  node_pool = "ingress"

  constraint {
    attribute = "${meta.machine}"
    operator  = "!="
    value     = "truenas"
  }
  constraint {
    attribute = "${meta.region}"
    operator  = "!="
    value     = "studio"
  }

  affinity {
    attribute = "${node.pool}"
    value     = "ingress"
    weight    = 50
  }

  spread {
    attribute = "${node.datacenter}"
  }

  update {
    auto_revert  = true
    auto_promote = true
    health_check = "task_states"
    stagger      = "30s"
    max_parallel = 3
    canary       = 1
  }

  group "web" {
    count = 2
    network {
      port "http"      { static = 80 }
      port "https"     { static = 443 }
      port "ssh"       { static = 2222 }
      port "dashboard" { static = 8080 }

      port "valheim"  { static = 2456 }
      port "valheim2" { static = 2457 }
      port "valheim3" { static = 2458 }

      port "minecraft" { static = 25565 }

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
          "dashboard",
          "valheim",
          "valheim2",
          "valheim3",
          "minecraft",
          "factorio",
        ]
      }
      resources {
        cpu = 200
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
        name = "traefik-dashboard"
        port = "dashboard"
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
        name = "traefik-minecraft"
        port = "minecraft"
      }

      service {
        name = "traefik-factorio"
        port = "factorio"
      }

      # Configuration
      template {
        data = <<-EOF
entryPoints:
  insecure:
    address: ':80'
    reusePort: true
    http:
      redirections:
        entryPoint:
          to: "secure"
          scheme: "https"
  secure:
    address: ':443'
    reusePort: true
    forwardedHeaders:
      trustedIPs:
        - '192.168.1.0/24'
        - '100.64.0.0/10'
    http:
      tls: {}

  ssh:
    reusePort: true
    address: ':2222'

  valheim:
    reusePort: true
    address: ':2456/udp'
  valheim2:
    reusePort: true
    address: ':2457/udp'
  valheim3:
    reusePort: true
    address: ':2458/udp'

  minecraft:
    reusePort: true
    address: ':25565/tcp'

  factorio:
    reusePort: true
    address: ':34197/udp'

providers:
  providersThrottleDuration: 2s
  file:
    watch: true
    directory: '/local/config'
  consulCatalog:
    watch: true
    endpoint:
      address: 'http://{{{ env "node.unique.network.ip-address" }}}:8500'
    defaultRule: "HostRegexp(`{{ normalize .Name }}.(services).demophoon.com`)"
    exposedByDefault: false

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
  {{- with secret "kv/data/apps/traefik/oauth" }}
  oidc-auth:
    plugin:
      traefik-oidc-auth:
        Provider:
          Url: "{{ .Data.data.provider }}"
          ClientId: "{{ .Data.data.client_id }}"
          ClientSecret: "{{ .Data.data.client_secret }}"
        Scopes: ["openid", "profile", "email"]
  {{- end }}

  tailscaleOnly:
    ipAllowList:
      sourcerange:
        - 127.0.0.1
        - 100.64.0.0/10
        EOF
        destination = "local/config/http-routers.yaml"
        change_mode = "noop"
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
            - certFile: "/secrets/certs/ff-cert.pem"
              keyFile: "/secrets/certs/ff-key.pem"
        EOF
        destination = "local/config/tls.yaml"
        change_mode = "noop"
      }

      template {
        data = <<-EOF
          {{ with secret "kv/data/traefik/certs/brittg-com" }}
          {{ .Data.data.cert | base64Decode }}
          {{ end }}
        EOF
        destination = "secrets/certs/cert.pem"
        perms = "600"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<-EOF
          {{ with secret "kv/data/traefik/certs/brittg-com" }}
          {{ .Data.data.key | base64Decode }}
          {{ end }}
        EOF
        destination = "secrets/certs/key.pem"
        perms = "600"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<-EOF
          {{ with secret "kv/data/traefik/certs/flawedfauna-com" }}
          {{ .Data.data.cert | base64Decode }}
          {{ end }}
        EOF
        destination = "secrets/certs/ff-cert.pem"
        perms = "600"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<-EOF
          {{ with secret "kv/data/traefik/certs/flawedfauna-com" }}
          {{ .Data.data.key | base64Decode }}
          {{ end }}
        EOF
        destination = "secrets/certs/ff-key.pem"
        perms = "600"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      vault {
        role = "traefik"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }
}
