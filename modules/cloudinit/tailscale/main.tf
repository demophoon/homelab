terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.28.0"
    }
  }
}

resource "tailscale_tailnet_key" "ts_key" {
  reusable      = false
  ephemeral     = true
  preauthorized = true
  tags          = compact(
    concat(
      [
        "tag:terraform_provisioned"
      ],
      var.additional_tags,
    )
  )
}
