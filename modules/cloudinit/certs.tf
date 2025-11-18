data "vault_kv_secret" "ssh_ca" {
  path = "proxmox/config/ca"
}

data "vault_generic_secret" "pki_ca" {
  path = "pki/cert/ca_chain"
}
