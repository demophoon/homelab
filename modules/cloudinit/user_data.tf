locals {
  cloudinit_cfg = templatefile(
    "${path.module}/templates/user_data.cfg",
    {
      hostname = var.hostname
      ts_key   = module.ts.tailscale_key

      backplane_ca      = var.backplane_certificate
      backplane_ca_b64  = base64encode(var.backplane_certificate)
      ssh_ca            = base64encode(data.vault_kv_secret.ssh_ca.data.public_key)
      sshd_config       = base64encode(file("${path.module}/templates/sshd_config"))
      nomad_config      = base64encode(local.nomad_config)
      consul_config     = base64encode(local.consul_config)
      vault_config      = base64encode(local.vault_config)
      keepalived_config = base64encode(local.keepalived_config)
      consul_pki_cert   = base64encode(vault_pki_secret_backend_cert.consul_internal.certificate)
      consul_pki_key    = base64encode(vault_pki_secret_backend_cert.consul_internal.private_key)
      start_cluster_sh  = base64encode(local.start_cluster_sh)

      include_keepalived = var.nomad_region == "cascadia" ? true : false
      advertise_routes   = var.nomad_region == "cascadia" ? true : false
    }
  )
}
