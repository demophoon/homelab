module "nomad-jobs" {
  source = "../../modules/nomad"

  autoscaler_version = "0.3.5"

  traefik_version = "v3.3.5"

  immich_version = "v1.134.0"

  homeassistant_version = "2025.4.3"
  zigbee2mqtt_version = "2.2.0"

  vaultwarden_version = "1.33.2" # renovate: datasource=docker depName=vaultwarden/server

  factorio_version = "1.1.110"

  nextcloud_version = "30.0.1"

  syncthing_version = "1.29.5"

  vikunja_version = "0.24.6"

  resume_version = "2024.05.13-0-11-gae40a35"

  shrls_version = "0.2.2"

  authentik_version = "2025.4.0"

  calibre_version = "3.0.4"
}
