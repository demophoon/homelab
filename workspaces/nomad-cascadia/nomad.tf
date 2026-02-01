module "nomad-jobs" {
  source = "../../modules/nomad-cascadia"

  autoscaler_version = "0.4.9" # image: hashicorp/nomad-autoscaler

  traefik_version = "v3.6.7" # image: traefik

  immich_version = "v2.4.1" # image: ghcr.io/immich-app/immich-server

  homeassistant_version = "2026.1.2" # image: homeassistant/home-assistant
  zigbee2mqtt_version = "2.7.2" # image: koenkk/zigbee2mqtt

  vaultwarden_version = "1.35.2" # image: vaultwarden/server

  nextcloud_version = "32.0.5" # image: nextcloud

  syncthing_version = "2.0.13" # image: syncthing/syncthing

  vikunja_version = "0.24.6" #image: vikunja/vikunja

  resume_version = "2024.05.13-0-14-g049aec3"

  shrls_version = "0.2.2"

  authentik_version = "2025.12.2" # image: ghcr.io/goauthentik/server

  calibre_version = "V3.0.4" # image: crocodilestick/calibre-web-automated
}
