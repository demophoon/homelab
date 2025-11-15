job "transmission" {
  datacenters = ["cascadia"]

  group "transmission" {
    count = 1

    network {
      port "transmission" { static = 9091 }
      #port "privoxy" { static = 8118 }
    }

    volume "data" {
      type = "host"
      source = "transmission-data"
    }
    volume "config" {
      type = "host"
      source = "transmission-config"
    }
    volume "ovpn" {
      type = "host"
      source = "transmission-ovpn"
    }

    task "transmission" {
      driver = "docker"

      template {
        data = <<EOF
        OPENVPN_PROVIDER = "CUSTOM"

        {{ with secret "kv/apps/transmission/openvpn" }}
        OPENVPN_CONFIG   = "{{ .Data.data.config }}"
        LOCAL_NETWORK = "{{ .Data.data.local_network }}"
        {{ end }}

        {{ with secret "kv/apps/vpn" }}
        OPENVPN_USERNAME = "{{ .Data.data.username }}"
        OPENVPN_PASSWORD = "{{ .Data.data.password }}"
        {{ end }}

        WEBPROXY_ENABLED = "false"
        WEBPROXY_PORT = "8118"
        OPENVPN_OPTS="--inactive 3600 --ping 10 --ping-exit 60"
        EOF
        env = true
        destination = "secrets/transmission.env"
      }

      config {
        image = "haugene/transmission-openvpn:5.3.2"

        ports = ["transmission"]
        cap_add = ["net_admin"]
        devices = [
          {
            host_path = "/dev/net/tun"
            container_path = "/dev/net/tun"
          },
        ]
      }

      volume_mount {
        volume = "config"
        destination = "/config"
      }
      volume_mount {
        volume = "data"
        destination = "/data"
      }
      volume_mount {
        volume = "ovpn"
        destination = "/etc/openvpn/custom/"
      }

      resources {
        cpu = 2000
        memory = 2048
        memory_max = 4096
      }

      service {
        name = "transmission"
        port = "transmission"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.transmission-internal.rule=Host(`transmission.internal.demophoon.com`)",
        ]
      }
    }
  }

  vault {
    policies = ["transmission"]
  }
}
