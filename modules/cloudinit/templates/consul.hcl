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
  defaults {
    ca_file   = "/opt/cluster/certs/backplane_ca.pem"
    cert_file = "/opt/cluster/certs/consul/cert.pem"
    key_file  = "/opt/cluster/certs/consul/priv.key"

    verify_incoming        = false
    verify_outgoing        = false
    verify_server_hostname = false
  }
  https {
    verify_incoming = false
  }
}

addresses {
  dns      = "127.0.0.1 {{ GetInterfaceIP \"eth0\" }} {{ GetInterfaceIP \"tailscale0\" }}",
  http     = "127.0.0.1 {{ GetInterfaceIP \"eth0\" }} {{ GetInterfaceIP \"tailscale0\" }}",
  grpc     = "127.0.0.1 {{ GetInterfaceIP \"eth0\" }} {{ GetInterfaceIP \"tailscale0\" }}",
  grpc_tls = "127.0.0.1 {{ GetInterfaceIP \"eth0\" }} {{ GetInterfaceIP \"tailscale0\" }}",
}

domain = "consul.demophoon.com."

connect {
  enabled = true
}

ports {
  https = 8501
  grpc = 8502
  grpc_tls = 8503
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
  address = "${truenas_ip}"
  port = 443
  tags = [
    "internal=true",
  ]
  check = {
    id = "api"
    name = "UI"
    http = "https://${truenas_ip}"
    tls_skip_verify = true
    method = "GET"
    interval = "10s"
    timeout = "1s"
  }
}

services {
  name = "plex"
  id = "plex"
  address = "${truenas_ip}"
  port = 32400
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.plex.rule=Host(`plex.brittg.com`)",
  ]
}

services {
  name = "media"
  id = "media"
  address = "${truenas_ip}"
  port = 15055
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.media.rule=Host(`media.internal.demophoon.com`)",
  ]
}
%{endif}
