resource "digitalocean_loadbalancer" "public" {
  count = local.has_load_balancer ? 1 : 0

  name   = "compute-lb"
  region = "sfo3"

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 443
    target_protocol = "https"

    tls_passthrough = true
  }

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 22
    entry_protocol = "tcp"

    target_port     = 2222
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port     = 2456
    entry_protocol = "udp"
    target_port     = 2456
    target_protocol = "udp"
  }
  forwarding_rule {
    entry_port     = 2457
    entry_protocol = "udp"
    target_port     = 2457
    target_protocol = "udp"
  }
  forwarding_rule {
    entry_port     = 2458
    entry_protocol = "udp"
    target_port     = 2458
    target_protocol = "udp"
  }

  forwarding_rule {
    entry_port     = 8448
    entry_protocol = "tcp"
    target_port     = 8448
    target_protocol = "tcp"
  }

  # Factorio
  forwarding_rule {
    entry_port     = 34197
    entry_protocol = "udp"
    target_port     = 34197
    target_protocol = "udp"
  }
  forwarding_rule {
    entry_port     = 34197
    entry_protocol = "tcp"
    target_port     = 34197
    target_protocol = "tcp"
  }

  healthcheck {
    port     = 443
    protocol = "tcp"
  }

  droplet_ids = flatten([
    for vm in module.vm-do : vm.id
  ])
}

resource "digitalocean_firewall" "default" {
  name = "default"

  droplet_ids = flatten([
    for vm in module.vm-do : vm.id
  ])

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "2222"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8080"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "2456-2458"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Empyrion
  inbound_rule {
    protocol         = "udp"
    port_range       = "30000-30004"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Factorio
  inbound_rule {
    protocol         = "udp"
    port_range       = "34197"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "34197"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Minecraft
  inbound_rule {
    protocol         = "udp"
    port_range       = "25565"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "25565"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

}
