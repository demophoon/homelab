module "nomad-jobs" {
  source = "../../modules/nomad"

  autoscaler_version = "0.4.6" # image: hashicorp/nomad-autoscaler

  traefik_version = "v3.4.3" # image: traefik

  immich_version = "v1.135.3" # image: ghcr.io/immich-app/immich-server

  homeassistant_version = "2025.7.1" # image: homeassistant/home-assistant
  zigbee2mqtt_version = "2.5.1" # image: koenkk/zigbee2mqtt

  vaultwarden_version = "1.34.1" # image: vaultwarden/server

  nextcloud_version = "31.0.6" # image: nextcloud

  syncthing_version = "1.30.0" # image: syncthing/syncthing

  vikunja_version = "0.24.6" #image: vikunja/vikunja

  resume_version = "2024.05.13-0-11-gae40a35"

  shrls_version = "0.2.2"

  authentik_version = "2025.6.3" # image: ghcr.io/goauthentik/server

  calibre_version = "V3.0.4" # image: crocodilestick/calibre-web-automated
}
