data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.cfg")
  vars = {
    hostname          = var.hostname
    ts_key            = module.ts.tailscale_key
    ssh_ca            = base64encode(data.vault_kv_secret.ssh_ca.data.public_key)
    sshd_config       = base64encode(data.template_file.sshd_config.rendered)
    nomad_config      = base64encode(data.template_file.nomad_config.rendered)
    consul_config     = base64encode(data.template_file.consul_config.rendered)
    vault_config      = base64encode(data.template_file.vault_config.rendered)
    keepalived_config = base64encode(data.template_file.keepalived_config.rendered)
    consul_pki_cert   = base64encode(vault_pki_secret_backend_cert.consul_internal.certificate)
    consul_pki_key    = base64encode(vault_pki_secret_backend_cert.consul_internal.private_key)
    start_cluster_sh  = base64encode(data.template_file.start_cluster_sh.rendered)

    include_keepalived = var.nomad_region == "cascadia" ? true : false
    advertise_routes   = var.nomad_region == "cascadia" ? true : false
  }
}
