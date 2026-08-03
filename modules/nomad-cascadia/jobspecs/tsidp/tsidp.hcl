variable "image_version" {
  type = string
  default = "v0.0.14" # image: ghcr.io/tailscale/tsidp
}

job "tsidp" {
  datacenters = ["cascadia"]

  group "tsidp" {
    network {
      port "app" { to = 443 }
    }

    task "app" {
      driver = "docker"

      config {
        image = "ghcr.io/tailscale/tsidp:${var.image_version}"
        ports = ["app"]
        volumes = [
          "/mnt/nfs/tsidp/data:/data",
        ]
      }

      template {
        data = <<-EOF
          TAILSCALE_USE_WIP_CODE=1 # tsidp is experimental - needed while version <1.0.0
          TS_STATE_DIR=/data # store persistent tsnet and tsidp state
          TS_HOSTNAME=idp # Hostname on tailnet (becomes idp.your-tailnet.ts.net)
          TSIDP_ENABLE_STS=1 # Enable OAuth token exchange
        EOF
        env = true
        destination = "local/env"
      }

      resources {
        cpu = 200
        memory = 256
        memory_max = 512
      }

      service {
        name = "tsidp"
        port = "app"
        tags = [
          "internal=true",
        ]
      }
    }
  }
}


