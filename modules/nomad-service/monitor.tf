data "uptimekuma_monitor_group" "production" {
  name = "Nomad Services - ${var.environment}"
}

data "uptimekuma_notification_gotify" "notify" {
  name = "Gotify (notifications.brittg.com)"
}

resource "uptimekuma_monitor_http" "this" {
  count = var.enable_monitoring ? 1 : 0

  name = var.name
  url = "https://${var.hostname}"
  parent = data.uptimekuma_monitor_group.production.id
  notification_ids = [data.uptimekuma_notification_gotify.notify.id]
}
