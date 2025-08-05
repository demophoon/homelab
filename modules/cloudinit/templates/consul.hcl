data_dir = "/opt/consul"
client_addr = "127.0.0.1 {{ GetInterfaceIP \"docker0\" }} {{ GetInterfaceIP \"eth0\" }} {{ GetInterfaceIP \"tailscale0\" }}"
bind_addr = "{{ GetInterfaceIP \"tailscale0\" }}"

%{if is_server}
bootstrap_expect = 3
%{endif}

server = ${is_server}
enable_local_script_checks = true

ui_config {
  enabled = true
}

node_meta {
  resource = "${resource}"
}

tls {
  https {
    cert_file = "/opt/consul/certs/cert.pem"
    key_file = "/opt/consul/certs/priv.key"
  }
}

addresses {
  dns = "127.0.0.1 {{ GetInterfaceIP \"eth0\" }} {{ GetInterfaceIP \"tailscale0\" }}",
  http = "127.0.0.1 {{ GetInterfaceIP \"eth0\" }} {{ GetInterfaceIP \"tailscale0\" }}",
  grpc = "127.0.0.1 {{ GetInterfaceIP \"eth0\" }} {{ GetInterfaceIP \"tailscale0\" }}",
}

domain = "consul.demophoon.com."

connect {
  enabled = true
}

ports {
  https = 8501
  grpc = 8502
}

telemetry {
  prometheus_retention_time = "10m"
}

%{if include_services}
# External Services
services {
  name = "tubeszb"
  id = "tubeszb"
  address = "192.168.1.114"
  tags = [
    "internal=true",
  ]
}

services {
  name = "truenas"
  id = "truenas"
  address = "192.168.1.163"
  port = 443
  tags = [
    "internal=true",
  ]
  check = {
    id = "api"
    name = "UI"
    http = "https://192.168.1.163"
    tls_skip_verify = true
    method = "GET"
    interval = "10s"
    timeout = "1s"
  }
}

services {
  name = "plex"
  id = "plex"
  address = "192.168.1.163"
  port = 32400
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.plex.rule=Host(`plex.brittg.com`)",
  ]
}

services {
  name = "media"
  id = "media"
  address = "192.168.1.163"
  port = 15055
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.media.rule=Host(`media.internal.demophoon.com`)",
  ]
}
%{endif}
