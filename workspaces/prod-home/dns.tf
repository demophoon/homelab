provider "google" {
  project     = "crypto-galaxy-246113"
  region      = "us-central1"
}

##===================================================
## Zones
##===================================================
resource "google_dns_managed_zone" "brittg_com" {
  name         = "dns01"
  dns_name     = "brittg.com."

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

resource "google_dns_managed_zone" "demophoon_com" {
  name         = "dns02"
  dns_name     = "demophoon.com."

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

resource "google_dns_managed_zone" "brittslittlesliceofheaven_org" {
  name         = "dns04"
  dns_name     = "brittslittlesliceofheaven.org."

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

resource "google_dns_managed_zone" "ddbbb_party" {
  name         = "ddbbb"
  dns_name     = "ddbbb.party."
}

resource "google_dns_record_set" "internal" {
  name         = "internal.demophoon.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.demophoon_com.name

  rrdatas = ["192.168.1.3"]
}

resource "google_dns_record_set" "cube" {
  name         = "cube.demophoon.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.demophoon_com.name

  rrdatas = ["192.168.1.163"]
}

##===================================================
## Records
##===================================================

## Valheim
##---------------------------------------------------
resource "google_dns_record_set" "valheim" {
  name         = "valheim.demophoon.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.demophoon_com.name

  rrdatas = ["compute-lb.demophoon.com."]
}

resource "google_dns_record_set" "valheim-brittg" {
  name         = "valheim.brittg.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name

  rrdatas = ["compute-lb.demophoon.com."]
}

resource "google_dns_record_set" "brittslittlesliceofheaven-catchall" {
  name         = "*.brittslittlesliceofheaven.org."
  #type         = "CNAME"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittslittlesliceofheaven_org.name

  #rrdatas = ["compute-lb.demophoon.com."]
  rrdatas = ["192.168.1.3"]
}

## Factorio
##---------------------------------------------------

resource "google_dns_record_set" "factorio-brittg" {
  name         = "_factorio._udp.factorio.brittg.com."
  type         = "SRV"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name

  rrdatas = [
    # Prefer local connections
    #"0 10 34197 cube.demophoon.com.",
    #"10 1 34197 internal.demophoon.com.",

    # Fallback to LB
    "50 0 34197 compute-lb.demophoon.com.",
  ]
}

resource "google_dns_record_set" "factorio-brittg-external" {
  name         = "_factorio._udp.factorio-external.brittg.com."
  type         = "SRV"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name

  rrdatas = [
    # Prefer local connections
    #"0 10 34197 cube.demophoon.com.",
    #"10 1 34197 internal.demophoon.com.",

    # Fallback to LB
    "50 0 34197 compute-lb.demophoon.com.",
  ]
}

# Protonmail Email
resource "google_dns_record_set" "brittg-mx" {
  name         = "brittg.com."
  type         = "MX"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name
  rrdatas = [
    "10 mail.protonmail.ch.",
    "20 mailsec.protonmail.ch.",
  ]
}

resource "google_dns_record_set" "brittg-root-txt" {
  name         = "brittg.com."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name
  rrdatas = [
    "protonmail-verification=b409c6d4e0bd28b90c4b057cf506cd1406b0b1a8",
    "\"v=spf1 include:_spf.protonmail.ch ~all\"",
  ]
}

resource "google_dns_record_set" "brittg-dkim-1" {
  name         = "protonmail._domainkey.brittg.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name
  rrdatas = [
    "protonmail.domainkey.dnrx26wnug6y6dc3q7dt7ll54pvs3lymrqfslkjxafze6mgizw36a.domains.proton.ch.",
  ]
}

resource "google_dns_record_set" "brittg-dkim-2" {
  name         = "protonmail2._domainkey.brittg.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name
  rrdatas = [
    "protonmail2.domainkey.dnrx26wnug6y6dc3q7dt7ll54pvs3lymrqfslkjxafze6mgizw36a.domains.proton.ch.",
  ]
}

resource "google_dns_record_set" "brittg-dkim-3" {
  name         = "protonmail3._domainkey.brittg.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name
  rrdatas = [
    "protonmail3.domainkey.dnrx26wnug6y6dc3q7dt7ll54pvs3lymrqfslkjxafze6mgizw36a.domains.proton.ch.",
  ]
}

resource "google_dns_record_set" "brittg-dmarc" {
  name         = "_dmarc.brittg.com."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name
  rrdatas = [
    "\"v=DMARC1; p=quarantine\"",
  ]
}

resource "google_dns_record_set" "brittg-root-did" {
  name         = "_atproto.brittg.com."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name
  rrdatas = [
    "did=did:plc:evt37vxklh6vllnuevsemdcy",
  ]
}

resource "google_dns_record_set" "demophoon-brittg-root-did" {
  name         = "_atproto.demophoon.brittg.com."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittg_com.name
  rrdatas = [
    "did=did:plc:evt37vxklh6vllnuevsemdcy",
  ]
}

resource "google_dns_record_set" "brittslittlesliceofheaven-root-txt" {
  name         = "brittslittlesliceofheaven.org."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittslittlesliceofheaven_org.name
  rrdatas = [
    "protonmail-verification=ee24a8a115b8ca5bf708ad8d3a7a835b855d2ca6",
    "\"v=spf1 include:_spf.protonmail.ch ~all\"",
  ]
}

resource "google_dns_record_set" "brittslittlesliceofheaven-mx" {
  name         = "brittslittlesliceofheaven.org."
  type         = "MX"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittslittlesliceofheaven_org.name
  rrdatas = [
    "10 mail.protonmail.ch.",
    "20 mailsec.protonmail.ch.",
  ]
}

resource "google_dns_record_set" "brittslittlesliceofheaven-dkim-1" {
  name         = "protonmail._domainkey.brittslittlesliceofheaven.org."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittslittlesliceofheaven_org.name
  rrdatas = [
    "protonmail.domainkey.dx56mcxpxywmfpjfsufdecpiqetqq7st5piryhlm3gfx6fhva5lwa.domains.proton.ch.",
  ]
}

resource "google_dns_record_set" "brittslittlesliceofheaven-dkim-2" {
  name         = "protonmail2._domainkey.brittslittlesliceofheaven.org."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittslittlesliceofheaven_org.name
  rrdatas = [
    "protonmail2.domainkey.dx56mcxpxywmfpjfsufdecpiqetqq7st5piryhlm3gfx6fhva5lwa.domains.proton.ch.",
  ]
}

resource "google_dns_record_set" "brittslittlesliceofheaven-dkim-3" {
  name         = "protonmail3._domainkey.brittslittlesliceofheaven.org."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittslittlesliceofheaven_org.name
  rrdatas = [
    "protonmail3.domainkey.dx56mcxpxywmfpjfsufdecpiqetqq7st5piryhlm3gfx6fhva5lwa.domains.proton.ch.",
  ]
}

resource "google_dns_record_set" "brittslittlesliceofheaven-dmarc" {
  name         = "_dmarc.brittslittlesliceofheaven.org."
  type         = "TXT"
  ttl          = 300
  managed_zone = google_dns_managed_zone.brittslittlesliceofheaven_org.name
  rrdatas = [
    "\"v=DMARC1; p=quarantine\"",
  ]
}

