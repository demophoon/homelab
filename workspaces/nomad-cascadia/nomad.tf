module "nomad-jobs" {
  source = "../../modules/nomad-cascadia"

  autoscaler_version = "0.4.9" # image: hashicorp/nomad-autoscaler

  traefik_version = "v3.6.8" # image: traefik

  immich_version = "v2.5.6" # image: ghcr.io/immich-app/immich-server

  homeassistant_version = "2026.2.1" # image: homeassistant/home-assistant
  zigbee2mqtt_version = "2.8.0" # image: koenkk/zigbee2mqtt

  vaultwarden_version = "1.35.3" # image: vaultwarden/server

  nextcloud_version = "32.0.5" # image: nextcloud

  syncthing_version = "2.0.14" # image: syncthing/syncthing

  vikunja_version = "1.1.0" #image: vikunja/vikunja

  resume_version = "2024.05.13-0-14-g049aec3"

  shrls_version = "0.2.2"

  authentik_version = "2025.12.4" # image: ghcr.io/goauthentik/server

  calibre_version = "V3.0.4" # image: crocodilestick/calibre-web-automated
}
