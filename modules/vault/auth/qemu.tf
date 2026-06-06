resource "vault_policy" "qemu" {
  name = "qemu"
  policy = <<-EOF
    path "kv/data/apps/qemu" {
      capabilities = ["read"]
    }

    # Get ssh certificate for VM access
    path "proxmox/config/ca" {
      capabilities = ["read"]
    }
    path "proxmox/roles/+" {
      capabilities = ["read", "list"]
    }
  EOF
}
