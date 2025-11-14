resource "nomad_job" "consul_backup" {
  jobspec = file("${path.module}/jobspecs/infrastructure-maint/consul-backup.hcl")
}

resource "nomad_job" "vault_unsealer" {
  jobspec = file("${path.module}/jobspecs/infrastructure-maint/vault-unseal.hcl")
}

resource "nomad_job" "terraform-apply" {
  jobspec = file("${path.module}/jobspecs/infrastructure-maint/terraform.hcl")
}
