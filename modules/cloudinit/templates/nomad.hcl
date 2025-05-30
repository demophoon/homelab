datacenter = "${region}"
data_dir  = "/opt/nomad"

%{if region == "cascadia"}
region = "global"
%{else}
region = "${region}"
%{endif}

bind_addr = "{{ GetInterfaceIP \"tailscale0\" }}"

server {
  enabled = ${is_server}
  %{if region == "cascadia"}
  bootstrap_expect = 3
  %{else}
  bootstrap_expect = 1
  %{endif}
}

client {
  enabled       = true
  network_interface = "tailscale0"

  node_class = "ephemeral"
  meta {
    provider = "${provider}"
    region = "${region}"
  }

  host_volume "docker-sock-ro" {
    path = "/var/run/docker.sock"
    read_only = true
  }

  %{if include_mounts}
  host_volume "docker-sock" {
    path = "/var/run/docker.sock"
  }

  host_volume "gpool0" { path = "/mnt/nfs/gpool0" }
  host_volume "media" { path = "/mnt/media" }

  # Home Assistant
  host_volume "homeassistant" { path = "/mnt/nfs/gpool0/services/homeassistant/homeassistant" }
  host_volume "appdaemon"     { path = "/mnt/nfs/gpool0/services/homeassistant/appdaemon" }
  host_volume "mosquitto"     { path = "/mnt/nfs/gpool0/services/homeassistant/mosquitto" }
  host_volume "zigbee2mqtt"   { path = "/mnt/nfs/gpool0/services/homeassistant/zigbee2mqtt/data" }

  # Vaultwarden
  host_volume "vaultwarden" {
    path = "/mnt/nfs/gpool0/services/vaultwarden"
  }

  # Authelia
  host_volume "authelia_config"  { path = "/mnt/nfs/gpool0/services/authelia/config" }
  host_volume "authelia_secrets" { path = "/mnt/nfs/gpool0/services/authelia/secrets" }
  host_volume "authelia_redis"   { path = "/mnt/nfs/gpool0/services/authelia/redis" }

  # Uptime Kuma
  host_volume "uptime_kuma" { path = "/mnt/nfs/uptime-kuma" }

  # Nextcloud
  host_volume "nextcloud_app" { path = "/mnt/nfs/nextcloud" }
  host_volume "nextcloud_db"  { path = "/mnt/nfs/nextcloud-db" }

  # Syncthing
  host_volume "syncthing" { path = "/mnt/nfs/syncthing" }

  # Immich
  host_volume "immich-upload"   { path = "/mnt/nfs/immich/uploads" }
  host_volume "immich-database" { path = "/mnt/nfs/immich/database" }

  # Plex
  host_volume "plex-config" { path = "/mnt/nfs/plex-config" }

  # Gitlab
  host_volume "gitlab-etc" { path = "/mnt/nfs/gitlab/etc" }
  host_volume "gitlab-log" { path = "/mnt/nfs/gitlab/log" }
  host_volume "gitlab-opt" { path = "/mnt/nfs/gitlab/opt" }

  # Static Files
  host_volume "local-static" { path = "/mnt/nfs/static" }

  # Grafana
  host_volume "grafana" { path = "/mnt/nfs/grafana" }
  host_volume "loki" { path = "/mnt/nfs/loki" }

  # Docker Registry
  host_volume "registry-data" { path = "/mnt/nfs/registry/data" }
  host_volume "registry-certs" { path = "/mnt/nfs/registry/certs" }
  host_volume "registry-auth" { path = "/mnt/nfs/registry/auth" }

  # Waypoint
  host_volume "waypoint-server" { path = "/mnt/nfs/waypoint/server" }
  host_volume "waypoint-runner" { path = "/mnt/nfs/waypoint/runner" }

  # Prometheus
  host_volume "prometheus-config" { path = "/mnt/nfs/prometheus/config" }
  host_volume "prometheus-data" { path = "/mnt/nfs/prometheus/data" }

  # Changedetection
  host_volume "changedetection" { path = "/mnt/nfs/changedetection" }

  # Minio
  host_volume "minio" { path = "/mnt/nfs/minio" }

  # Mastodon
  host_volume "mastodon-db" { path = "/mnt/nfs/mastodon/db" }
  host_volume "mastodon-redis" { path = "/mnt/nfs/mastodon/redis" }
  host_volume "mastodon-es" { path = "/mnt/nfs/mastodon/elasticsearch" }

  # Truecommand
  host_volume "truecommand" { path = "/mnt/nfs/truecommand" }

  # Empyrion
  host_volume "empyrion-steam" { path = "/mnt/nfs/empyrion/steam" }
  host_volume "empyrion-data" { path = "/mnt/nfs/empyrion/data" }

  # Valheim
  host_volume "valheim-config" { path = "/mnt/nfs/valheim/config" }
  host_volume "valheim-data" { path = "/mnt/nfs/valheim/data" }

  # Synapse
  host_volume "synapse-data" { path = "/mnt/nfs/synapse/data" }
  %{endif}
}

consul {
  address = "127.0.0.1:8500"
  tags = ["ephemeral"]
  server_auto_join = ${is_server}
}

vault {
  enabled = true
  address = "https://active.vault.service.consul.demophoon.com:8200"
  create_from_role = "nomad-cluster"

  default_identity {
    aud = ["vault.io"]
    env = false
    file = false
    ttl = "1h"
  }
}

keyring "transit" {
  active = true
  name   = "example"

  key_name   = "nomad-server"
  mount_path = "transit/"
}

telemetry {
  prometheus_metrics = true
}

plugin "docker" {
  config {
    pull_activity_timeout = "10m"
    allow_privileged = true
    allow_caps = ["all"]
    volumes {
      enabled = true
    }
    extra_labels = ["job_name", "task_group_name", "task_name", "namespace", "node_name"]
  }
}

ui {
  enabled = true
}

tls {
  http = true
  cert_file = "/opt/nomad/certs/cert.pem"
  key_file = "/opt/nomad/certs/priv.key"
}
