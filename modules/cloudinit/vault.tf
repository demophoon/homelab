data "template_file" "vault_config" {
  template = file("${path.module}/templates/vault.hcl")
}
