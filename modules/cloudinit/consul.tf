resource "vault_pki_secret_backend_cert" "consul_internal" {
  backend = "pki"
  name = "backplane"
  alt_names = [var.hostname, "${var.hostname}.dc1.consul.demophoon.com"]
  common_name = "consul.service.consul.demophoon.com"
}

#TODO: Replace this with a read only token so that we can bootstrap consul.
#
# The idea is that because we require consul to be up to discover the other
# services, like nomad and vault. We should make this initial token read only
# to find vault. Once we authenticate with Vault with our Approle token, we
# can retrieve our real consul token that has been stuffed away in the Approle
# cubby and use that for the rest of our consul interactions. This keeps more
# dangerous tokens out of cloud-init, and more importantly, out of the Terraform
# state file.
# Note: This is still something we need to solve with the Tailscale token but
# with the one-time use keys and Tailscale ACLs that are in place, our blast
# radius is somewhat limited. It won't prevent an attacker from using the
# Tailscale token to access the network during the provisioning period but will
# cause the node being provisioned to fail and set off alarms that a token has
# been used where it wasn't suppose to be used, a primary goal of using Approle.
data "vault_generic_secret" "consul_default_token" {
  path = "consul/creds/${local.token_role}"
}

locals {
  token_role    = var.server ? "consul_server_node" : "consul_agent_node"
  consul_config = templatefile(
    "${path.module}/templates/consul.hcl",
    {
      is_server        = var.server
      include_services = var.nomad_region == "cascadia" ? true : false
      resource         = var.resource
      truenas_ip       = var.truenas_ip
      default_token    = data.vault_generic_secret.consul_default_token.data.token
    }
  )
}
