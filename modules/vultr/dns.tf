resource "google_dns_record_set" "dns" {
  name         = "${random_pet.server_name.id}.demophoon.com."
  type         = "A"
  ttl          = 300
  managed_zone = var.gcp_zone

  rrdatas = [vultr_instance.web.main_ip]
}
