module "nomad-jobs" {
  source = "../../modules/nomad-digitalocean"

  traefik_version = "v3.5.0" # image: traefik

  resume_version = "2024.05.13-0-11-gae40a35"
}
