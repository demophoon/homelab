variable "image_version" {
  type = string
  default = "v3.1"
}
variable "region" {
  type = string
}

job "traefik" {
  datacenters = ["cascadia"]
  region = "${var.region}"
  priority = 100

  type = "system"

  group "web" {
    count = 1
    network {
      port "http"      { static = 80 }
      port "https"     { static = 443 }
      port "ssh"       { static = 2222 }
      port "dashboard" { static = 8080 }

      port "valheim"  { static = 2456 }
      port "valheim2" { static = 2457 }
      port "valheim3" { static = 2458 }

      port "factorio" { static = 34197 }

      port "otel" { static = 4318 }
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
          "factorio",
          "otel",
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
        name = "traefik-otel"
        port = "otel"
      }

      service {
        name = "traefik-factorio"
        port = "factorio"
      }

      # Configuration
      template {
        data = <<-EOF
api:
  dashboard: true

entryPoints:
  traefik:
    address: ':8081'
  internal:
    address: ':8082'
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

  waypoint:
    address: ':9701'
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

  vault:
    address: ':4200'

providers:
  providersThrottleDuration: 2s
  file:
    watch: true
    directory: '/local/config'
  consulCatalog:
    watch: true
    endpoint:
      address: 'http://{{{ env "node.unique.network.ip-address" }}}:8500'
    defaultRule: "HostRegexp(`{{ normalize .Name }}.(ts|internal|services).demophoon.com`)"
    exposedByDefault: true

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
http:
  serversTransports:
    vault-transport:
      serverName: "vault.service.consul.demophoon.com"
      insecureSkipVerify: true
    consul-transport:
      serverName: "consul.service.consul.demophoon.com"
      insecureSkipVerify: true
    nomad-transport:
      serverName: "nomad.service.consul.demophoon.com"
      insecureSkipVerify: true
  routers:
    api:
      entrypoints:
        - secure
      rule: "Host(`dashboard.internal.demophoon.com`)"
      service: api@internal
    vault-int:
      entrypoints:
        - secure
      rule: "Host(`vault-ui.internal.demophoon.com`) || Host(`vault.ts.demophoon.com`)"
      service: vault-int@file
    consul-int:
      entrypoints:
        - secure
      rule: "Host(`consul-ui.internal.demophoon.com`) || Host(`consul.ts.demophoon.com`)"
      service: consul-int@file
    nomad-int:
      entrypoints:
        - secure
      rule: "Host(`nomad-ui.internal.demophoon.com`) || Host(`nomad.ts.demophoon.com`)"
      service: nomad-int@file

    consul-do:
      entrypoints:
        - secure
      rule: "Host(`consul-do.internal.demophoon.com`)"
      service: consul-do@file
    nomad-do:
      entrypoints:
        - secure
      rule: "Host(`nomad-do.internal.demophoon.com`)"
      service: nomad-do@file
  services:
    vault-int:
      loadBalancer:
        serversTransport: vault-transport
        servers:
          {{- range service "active.vault" }}
          - url: "https://{{ .Address }}:{{ .Port }}"
          {{- end }}
    consul-int:
      loadBalancer:
        serversTransport: consul-transport
        servers:
          {{- range service "active.vault" }}
          - url: "https://{{ .Address }}:8501"
          {{- end }}
    nomad-int:
      loadBalancer:
        serversTransport: nomad-transport
        servers:
          {{- range service "active.vault" }}
          - url: "https://{{ .Address }}:4646"
          {{- end }}

    consul-do:
      loadBalancer:
        serversTransport: nomad-transport
        servers:
          {{- range nodes }}{{ if .Node | contains "do-" }}
          - url: "https://{{ .Address }}:8501"
          {{- end }}{{- end }}
    nomad-do:
      loadBalancer:
        serversTransport: nomad-transport
        servers:
          {{- range nodes }}{{ if .Node | contains "do-" }}
          - url: "https://{{ .Address }}:4646"
          {{- end }}{{- end }}


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
              stores:
                - "default"
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
        change_mode = "noop"
      }
      template {
        data = <<-EOF
          {{ with secret "kv/data/traefik/certs/brittg-com" }}
          {{ .Data.data.key | base64Decode }}
          {{ end }}
        EOF
        destination = "secrets/certs/key.pem"
        perms = "600"
        change_mode = "noop"
      }
    }
  }

  vault {
    role = "traefik"
  }
}
