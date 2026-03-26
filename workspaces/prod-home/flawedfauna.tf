resource "google_dns_managed_zone" "flawedfauna_com" {
  name         = "ffdns01"
  dns_name     = "flawedfauna.com."

  dnssec_config {
    kind          = "dns#managedZoneDnsSecConfig"
    non_existence = "nsec3"
    state         = "off"

    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = "keySigning"
      kind       = "dns#dnsKeySpec"
    }
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 1024
      key_type   = "zoneSigning"
      kind       = "dns#dnsKeySpec"
    }
  }
}

resource "google_dns_record_set" "flawedfauna-catchall" {
  name         = "*.flawedfauna.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.flawedfauna_com.name

  rrdatas = ["compute-lb.demophoon.com."]
}

