module "nomad-jobs" {
  source = "../../modules/nomad-cascadia"

  autoscaler_version = "0.4.6" # image: hashicorp/nomad-autoscaler

  traefik_version = "v3.4.3" # image: traefik

  immich_version = "v2.1.0" # image: ghcr.io/immich-app/immich-server

  homeassistant_version = "2025.10.1" # image: homeassistant/home-assistant
  zigbee2mqtt_version = "2.6.2" # image: koenkk/zigbee2mqtt

  vaultwarden_version = "1.34.1" # image: vaultwarden/server

  nextcloud_version = "31.0.7" # image: nextcloud

  syncthing_version = "2.0.10" # image: syncthing/syncthing

  vikunja_version = "0.24.6" #image: vikunja/vikunja

  resume_version = "2024.05.13-0-14-g049aec3"

  shrls_version = "0.2.2"

  authentik_version = "2025.10.1" # image: ghcr.io/goauthentik/server

  calibre_version = "V3.0.4" # image: crocodilestick/calibre-web-automated
}
