variable "image_version" {
  type = string
  default = "v3.5.0"
}

job "traefik" {
  datacenters = ["cascadia"]
  region = "global"
  priority = 100

  update {
    auto_revert  = true
    health_check = "task_states"
    stagger      = "30s"
    max_parallel = 1
  }

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

      port "minecraft" { static = 25565 }

      port "factorio" { static = 34197 }

      port "otel" { static = 4318 }

      port "internal" { static = 8082 }
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
          "otel",
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
        name = "traefik-otel"
        port = "otel"
      }

      service {
        name = "traefik-factorio"
        port = "factorio"
      }

      service {
        name = "traefik-internal"
        port = "internal"
        check {
          name     = "traefik-internal-health"
          type     = "http"
          interval = "5s"
          timeout  = "1s"
          path     = "/ping"
        }
      }

      # Configuration
      template {
        data = <<-EOF
api:
  dashboard: true

ping:
  entryPoint: "internal"

entryPoints:
{{{- if env "meta.region" | eq "cascadia" }}}
  traefik:
    address: ':8081'
  internal:
    address: ':8082'
{{{- end }}}

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
{{- if env "meta.region" | eq "cascadia" }}
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
      rule: "Host(`consul-do.internal.demophoon.com`) || Host(`consul-do.ts.demophoon.com`)"
      service: consul-do@file
    nomad-do:
      entrypoints:
        - secure
      rule: "Host(`nomad-do.internal.demophoon.com`) || Host(`nomad-do.ts.demophoon.com`)"
      service: nomad-do@file

    truenas:
      entrypoints:
        - secure
      rule: "Host(`truenas.ts.demophoon.com`)"
      service: truenas@file
    beryllium:
      entrypoints:
        - secure
      rule: "Host(`proxmox-beryllium.ts.demophoon.com`)"
      service: proxmox-beryllium@file
    nuc:
      entrypoints:
        - secure
      rule: "Host(`proxmox-nuc.ts.demophoon.com`)"
      service: proxmox-nuc@file
    sol:
      entrypoints:
        - secure
      rule: "Host(`proxmox-sol.ts.demophoon.com`)"
      service: proxmox-sol@file

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
    truenas:
      loadBalancer:
        serversTransport: nomad-transport
        servers:
          - url: "https://192.168.1.163:443"
          {{- range service "truenas" }}
          - url: "https://{{ .Address }}:443"
          {{- end }}
    proxmox-beryllium:
      loadBalancer:
        serversTransport: nomad-transport
        servers:
          - url: "https://192.168.1.4:8006"
    proxmox-nuc:
      loadBalancer:
        serversTransport: nomad-transport
        servers:
          - url: "https://192.168.1.35:8006"
    proxmox-sol:
      loadBalancer:
        serversTransport: nomad-transport
        servers:
          - url: "https://192.168.1.220:8006"
{{- end }}

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
