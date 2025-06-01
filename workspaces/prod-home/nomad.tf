module "nomad-jobs" {
  source = "../../modules/nomad"

  autoscaler_version = "0.3.5" # image: hashicorp/nomad-autoscaler

  traefik_version = "v3.3.5" # image: traefik

  immich_version = "v1.134.0" # image: ghcr.io/immich-app/immich-server

  homeassistant_version = "2025.4.3" # image: homeassistant/home-assistant
  zigbee2mqtt_version = "2.2.0" # image: koenkk/zigbee2mqtt

  vaultwarden_version = "1.33.2" # image: vaultwarden/server

  nextcloud_version = "30.0.1" # image: nextcloud

  syncthing_version = "1.29.5" # image: syncthing/syncthing

  vikunja_version = "0.24.6" #image: vikunja/vikunja

  resume_version = "2024.05.13-0-11-gae40a35"

  shrls_version = "0.2.2"

  authentik_version = "2025.4.0" # image: ghcr.io/goauthentik/server

  calibre_version = "V3.0.4" # image: crocodilestick/calibre-web-automated
}
