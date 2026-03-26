terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.28.0"
    }
  }
}

resource "null_resource" "created_at" {
  triggers = {
    timestamp = timestamp()
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
