terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.29.2"
    }
  }
}

resource "null_resource" "created_at" {
  triggers = {
    hostname = var.hostname
  }
}

resource "tailscale_tailnet_key" "ts_key" {
  reusable      = false
  ephemeral     = true
  preauthorized = true
  tags          = compact(
    concat(
      [
        "tag:terraform-provisioned"
      ],
      var.additional_tags,
    )
  )

  lifecycle {
    replace_triggered_by = [
      null_resource.created_at,
    ]
  }
}
