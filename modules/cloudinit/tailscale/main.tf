terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.25.0"
    }
  }
}

resource "tailscale_tailnet_key" "ts_key" {
  reusable      = true
  ephemeral     = true
  preauthorized = true
}
