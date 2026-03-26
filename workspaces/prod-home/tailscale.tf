locals {
  tags = {
    // This node is offsite
    "tag:offsite" = ["autogroup:network-admin"],
    // Node has been provisioned with Terraform
    "tag:terraform-provisioned" = ["autogroup:network-admin"],
    // Nomad client is running on this node
    "tag:nomad-client" = ["tag:terraform-provisioned"],
    // This node can provision nomad jobs for the cluster
    "tag:nomad-server" = ["tag:terraform-provisioned"],
    // This node runs Vault
    "tag:vault-server" = ["tag:terraform-provisioned"],
    // This node runs Consul server
    "tag:consul-server" = ["tag:terraform-provisioned"],
    // This node runs Miren
    "tag:miren" = ["tag:terraform-provisioned"],
    // This node is publicly available as an ingress node
    "tag:ingress" = ["tag:terraform-provisioned"],
  }

  grants = [
    // Nomad Servers can talk to each other
    {
      "src" = ["tag:nomad-server"],
      "dst" = ["tag:nomad-server"],
      "ip"  =  ["tcp:4648", "udp:4648"],
    },
    // Nomad Servers can talk to Nomad Clients
    {
      "src" = ["tag:nomad-server", "tag:nomad-client"],
      "dst" = ["tag:nomad-server", "tag:nomad-client"],
      "ip"  = ["tcp:4646-4647"],
    },
    // Nomad can talk to Vault
    {
      "src" = ["tag:nomad-client"],
      "dst" = ["tag:vault-server"],
      "ip"  = ["tcp:8200"],
    },
    // Ingress nodes can communicate with nomad-clients to route services
    {
      "src" = ["tag:ingress"],
      "dst" = ["tag:nomad-client"],
      "ip"  = ["tcp:20000-32000"],
    },
    // Match absolutely everything.
    // Comment this section out if you want to define specific restrictions.
    {
      "src" = ["*"],
      "dst" = ["*"],
      "ip"  = ["*"],
    },
  ]
}
resource "tailscale_acl" "json" {
  acl = jsonencode({
    autoApprovers = {
      services = {
	"svc:nomad" = ["tag:nomad-server"]
      }
    },
    nodeAttrs = [
      {
	// Funnel policy, which lets tailnet members control Funnel
	// for their own devices.
	// Learn more at https://tailscale.com/kb/1223/tailscale-funnel/
	target = ["autogroup:members"],
	attr = ["funnel"],
      },
    ],
    ssh = [
      // Allow all users to SSH into their own devices in check mode.
      // Comment this section out if you want to define specific restrictions.
      {
	action = "check",
	src    = ["autogroup:members"],
	dst    = ["autogroup:self"],
	users  = ["autogroup:nonroot", "root"],
      },
    ],
    grants = local.grants,
    tagOwners = local.tags,
  })
}
