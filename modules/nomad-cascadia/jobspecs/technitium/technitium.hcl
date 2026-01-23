variable "image_version" {
  type = string
  default = "14.3.0"
}

job "technitium" {
  datacenters = ["cascadia"]
  node_pool = "nas"

  group "technitium" {
    network {
      port "app" { static = 5380 }
      port "dns" { static = 53 }
    }

    task "app" {
      driver = "docker"

      config {
        network_mode = "host"
        image = "technitium/dns-server:${var.image_version}"
        ports = ["app", "dns"]
        volumes = [
          "/mnt/dank0/andromeda/technitium/config:/etc/dns",
        ]
      }

      template {
        data = <<-EOT
          # The primary domain name used by this DNS Server to identify itself.
          DNS_SERVER_DOMAIN=dns.internal.demophoon.com
          # DNS web console admin user password.

          # DNS_SERVER_WEB_SERVICE_HTTP_PORT=5380 #The TCP port number for the DNS web console over HTTP protocol.
          # DNS_SERVER_WEB_SERVICE_HTTPS_PORT=53443 #The TCP port number for the DNS web console over HTTPS protocol.
          # DNS_SERVER_WEB_SERVICE_ENABLE_HTTPS=false #Enables HTTPS for the DNS web console.
          # DNS_SERVER_WEB_SERVICE_USE_SELF_SIGNED_CERT=false #Enables self signed TLS certificate for the DNS web console.
          # DNS_SERVER_WEB_SERVICE_TLS_CERTIFICATE_PATH=/etc/dns/tls/cert.pfx #The file path to the TLS certificate for the DNS web console.
          # DNS_SERVER_WEB_SERVICE_TLS_CERTIFICATE_PASSWORD=password #The password for the TLS certificate for the DNS web console.
          # DNS_SERVER_WEB_SERVICE_HTTP_TO_TLS_REDIRECT=false #Enables HTTP to HTTPS redirection for the DNS web console.
          # DNS_SERVER_OPTIONAL_PROTOCOL_DNS_OVER_HTTP=false #Enables DNS server optional protocol DNS-over-HTTP on TCP port 8053 to be used with a TLS terminating reverse proxy like nginx.
          # DNS_SERVER_RECURSION=AllowOnlyForPrivateNetworks #Recursion options: Allow, Deny, AllowOnlyForPrivateNetworks, UseSpecifiedNetworkACL.
          # DNS_SERVER_RECURSION_NETWORK_ACL=192.168.10.0/24, !192.168.10.2 #Comma separated list of IP addresses or network addresses to allow access. Add ! character at the start to deny access, e.g. !192.168.10.0/24 will deny entire subnet. The ACL is processed in the same order its listed. If no networks match, the default policy is to deny all except loopback. Valid only for `UseSpecifiedNetworkACL` recursion option.
          # DNS_SERVER_RECURSION_DENIED_NETWORKS=1.1.1.0/24 #Comma separated list of IP addresses or network addresses to deny recursion. Valid only for `UseSpecifiedNetworkACL` recursion option. This option is obsolete and DNS_SERVER_RECURSION_NETWORK_ACL should be used instead.
          # DNS_SERVER_RECURSION_ALLOWED_NETWORKS=127.0.0.1, 192.168.1.0/24 #Comma separated list of IP addresses or network addresses to allow recursion. Valid only for `UseSpecifiedNetworkACL` recursion option.  This option is obsolete and DNS_SERVER_RECURSION_NETWORK_ACL should be used instead.
          # DNS_SERVER_ENABLE_BLOCKING=false #Sets the DNS server to block domain names using Blocked Zone and Block List Zone.
          # DNS_SERVER_ALLOW_TXT_BLOCKING_REPORT=false #Specifies if the DNS Server should respond with TXT records containing a blocked domain report for TXT type requests.
          # DNS_SERVER_BLOCK_LIST_URLS= #A comma separated list of block list URLs.
          # DNS_SERVER_FORWARDERS=1.1.1.1, 8.8.8.8 #Comma separated list of forwarder addresses.
          # DNS_SERVER_FORWARDER_PROTOCOL=Tcp #Forwarder protocol options: Udp, Tcp, Tls, Https, HttpsJson.
          # DNS_SERVER_LOG_USING_LOCAL_TIME=true #Enable this option to use local time instead of UTC for logging.
        EOT
        destination = "secrets/config"
        env = true
      }

      resources {
        cpu = 200
        memory = 256
        memory_max = 1024
      }

      service {
        name = "technitium-app"
        port = "app"
        tags = [
          "traefik.enable=true",
          "internal=true",
          "traefik.http.routers.technitium-app.rule=host(`dns.internal.demophoon.com`)",
        ]
      }
    }
  }
}

