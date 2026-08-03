#data "tailscale_service" "internal" {
#  name = "svc:internal"
#}

resource "google_dns_record_set" "demophoon-ts" {
  name         = "*.ts.demophoon.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.demophoon_com.name

  rrdatas = ["100.113.204.81"]
}

