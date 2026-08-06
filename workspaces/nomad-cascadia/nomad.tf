module "nomad-jobs" {
  source = "../../modules/nomad-cascadia"

  resume_version = "2024.05.13-0-14-g049aec3"
  shrls_version = "0.2.2"
}
