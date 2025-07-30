resource "nomad_acl_policy" "readonly" {
  name        = "readonly"
  description = "Read only access to the Nomad cluster."
  rules_hcl   = file("${path.module}/policies/readonly.hcl")
}

resource "nomad_acl_policy" "write" {
  name        = "write"
  description = "Write access to the Nomad cluster."
  rules_hcl   = file("${path.module}/policies/write.hcl")
}
