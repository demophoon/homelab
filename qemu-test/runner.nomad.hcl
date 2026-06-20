job "runner" {
  datacenters = ["cascadia"]
  node_pool = "nuc"

  update {
    auto_revert  = true
    auto_promote = true
    health_check = "task_states"
    stagger      = "5m"
    max_parallel = 1
    canary       = 1
    min_healthy_time = "5m"
    healthy_deadline = "10m"
    progress_deadline = "15m"
  }

  group "ubuntu" {
    scaling {
      enabled = true
      min     = 1
      max     = 6
    }

    ephemeral_disk {
      size = 51200
    }

    network {
      port "novnc" {}
    }

    task "disk-prepare" {
      driver = "raw_exec"
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      config {
        command = "/bin/sh"
        args = ["-c", "${NOMAD_TASK_DIR}/prepare.sh"]
      }

      template {
        destination = "${NOMAD_TASK_DIR}/prepare.sh"
        perms = "755"
        data = <<-EOH
        #!/bin/sh
        set -eux
        /usr/bin/qemu-img resize ${NOMAD_ALLOC_DIR}/data/noble-server-cloudimg-amd64.img 40G
        EOH
      }
      artifact {
        source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
        destination = "${NOMAD_ALLOC_DIR}/data"
      }
    }

    task "cloudinit" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "docker"
      config {
        image = "francoishill/docker-mkisofs:latest"
        args = [
          "genisoimage",
          "-output", "/alloc/data/seed.iso",
          "-volid", "cidata",
          "-rational-rock",
          "-joliet", "/local/user-data",
          "/local/meta-data"
        ]
      }

      template {
        destination = "local/meta-data"
        data = <<EOH
        {
          "v1": {
            "instance_id": "runner-{{ env "NOMAD_SHORT_ALLOC_ID" }}",
            "local_hostname": "runner-{{ env "NOMAD_SHORT_ALLOC_ID" }}"
          }
        }
        EOH
      }

      template {
        destination = "local/user-data"
        once = true
        data = <<EOH
#cloud-config
hostname: {{ env "NOMAD_JOB_NAME" }}-{{ env "NOMAD_SHORT_ALLOC_ID" }}
ssh_pwauth: no
manage_etc_hosts: true
package_update: true
package_upgrade: true
disable_root: true

growpart:
  mode: auto
  devices: ["/"]
  ignore_growroot_disabled: false
resize_rootfs: true

ssh:
  emit_keys_to_console: false

groups:
  - docker

ca_certs:
  trusted:
    # Legacy Vault
    - |
      -----BEGIN CERTIFICATE-----
      MIIDbTCCAlWgAwIBAgIUSfFbbeogDEV/7N8W/6Eh5KjIqswwDQYJKoZIhvcNAQEL
      BQAwKDEmMCQGA1UEAxMdY29uc3VsLnNlcnZpY2VzLmRlbW9waG9vbi5jb20wHhcN
      MjIwNzE0MDIzOTQ4WhcNMzIwNzExMDI0MDE4WjAoMSYwJAYDVQQDEx1jb25zdWwu
      c2VydmljZXMuZGVtb3Bob29uLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
      AQoCggEBAOAAqrLGmkBQ0pyfXckOylsUh/5fvuxGLK97bb5GyhsdEtDVuk7Gmt5i
      NGt6Q3gN3OtzseWmfzN6EKa+kCy4QAXXXSUxv8iznOxnwqYyCcUsTX3dlHIlCLgU
      TtI0BnrB55YgPkrXe8Du4DQiHx6aSXioF0gIrRgVPdtQg1+Has2kzLeLumkiI4Zj
      /+FA3t1NWlqkDG9pCfm2AkSsC2Snx/eUMWzuV1kTYkOXN6cmLXF7BId2Y4tbBG0i
      33BTZfY6/MkWkm4GYQainYGG+WW6F+MHmgwx4B3nwpcwqxyk8GF4vjQ7IQlPf2Ku
      Sbb1Nt3deOWehSVeSIaUBFG953d/aJMCAwEAAaOBjjCBizAOBgNVHQ8BAf8EBAMC
      AQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUV1It885u2ER42g6lUF/3JVRh
      wCAwHwYDVR0jBBgwFoAUV1It885u2ER42g6lUF/3JVRhwCAwKAYDVR0RBCEwH4Id
      Y29uc3VsLnNlcnZpY2VzLmRlbW9waG9vbi5jb20wDQYJKoZIhvcNAQELBQADggEB
      AHfs1Z9N1D8LluxMkQZmOX7y01tZ/P1MFSnbkyVERMFD2JfisL3FXSZNUBaL9t8l
      aNC6ZrkKOD8AF5J6i1LciNnmJZT/qkGGNuGI/tLWlxPLyMe5lZbpWpHyvdVBRdjo
      /i8cd3mePMzMlhi2yX6Ht5dOkFi7XupMMw9DlEeOzxv1Rlj2MaW1dXxijJLd3oto
      S2h8TAzKaBVL8yKiiilWZvWG9RHmiG3Rx/83tng5XMDBLpmra8KOFaK/Q0JJEjGL
      J1C5MDqPoeAcvhtRH4tr2YN/MBsxBxF4HIWoQkUhZQ7UNEEuS36zGizqaSWT/Sil
      0uIz3uOy/6H6p0TO0yQbdyQ=
      -----END CERTIFICATE-----

chpasswd:
  expire: false
  users:
    - name: "britt"
      password: "$6$w3HX3vUYWY864jM0$EKv0ymf6ZelHp9.5ockQwKqz89V6SwvCeI9QXPJGjdCXs0GjkdT5R4CDBE.pWvcbf4DgR4sTBkmBib5GfYFFu0"

users:
  - name: runner
    groups: docker
  - name: "britt"
    sudo: ALL=(ALL:ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      # Yk5
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDUXBV+G5DPbpqMici/SOA6SiH0fV4buXEysz5fdunByIcpdH1yrCCeIzUnGAq6nXinQmV4LiApR9o98RMAEtm/G4lSLcK/zDk3a5NGPDsii+DsoATyLy6407rAErhg+ZZrLW8P9eS8yDGDDSmb1L1b6C0L+SyCjKi509xcYW7M5uiedO0iYNFPCwzb+6JQVz03D7Xa3hg5dSEPQE2C7Nfh7LiXxbcd+q05MvtqoSw9zbn5SFh6k3ykrup3qZD1mxTCtF8XBss6kyn7Um0cfNOVWsQZFs6hR91ODMfH8CkR0HWngmmX86YkQkrEJ6rDAwIOIyjacByLdNgldCe9i0yNIFGV6VO+TWbmWju8sjh2oR2VbFjTSWOi8nkRET7c4ExTRWH+mY3wCIG2AIZ+ugfV6HotpbjUHgyUmHhFjBNmzNkJrEGmg7MZ3uAYWONHsw+O/+CuSknwFCXq+1EJXqQoct9gqLZ4XWcy0pJGtGAtgjpXqp0rTXGmYxwLV7m0E07kq0zypmBv7NGyY43O9siETAPd5WusoF4mUP+oVSahzBdy4qd2bClZf+oEvJ2zBewCaESYMsvQ6wbmsDVUpOx+rvi+K39bBEpcD1KkCy2FKzXyUqrUszQTEMqhynRWtP5XVyEjbo1+WLYcFYFePYC9G0meL7S52l7aSzZx2iHxGw==

ansible:
  package_name: ansible-core
  install_method: pip
  pull:
    url: https://git.brittg.com/demophoon/homelab.git
    checkout: main
    playbook_name: ansible/runner-setup.yml

write_files:
  - path: /home/runner/runner-token.sh
    permissions: '0700'
    content: |
      #!/bin/sh

      {{ with secret "kv/apps/forgejo/runner" }}
      curl -X 'POST' \
        'https://git.brittg.com/api/v1/admin/actions/runners' \
        -H 'accept: application/json' \
        -H 'Authorization: Bearer {{ .Data.data.registration_token }}' \
        -H 'Content-Type: application/json' \
        -d '{
        "name": "{{ env "NOMAD_JOB_NAME" }}-{{ env "NOMAD_ALLOC_INDEX" }}-{{ env "NOMAD_SHORT_ALLOC_ID" }}"
      }' > /home/runner/registration.json
      {{ end }}

      jq -r '.token' /home/runner/registration.json > /home/runner/token
      jq -r '.uuid' /home/runner/registration.json > /home/runner/uuid

      echo "      token: $(cat /home/runner/token)" >> /home/runner/runner-config.yml
      echo "      uuid: $(cat /home/runner/uuid)" >> /home/runner/runner-config.yml
      chown runner:runner /home/runner/runner-config.yml
      mkdir -p /home/runner/.cache
      chown runner:runner /home/runner/.cache

  {{ with secret "proxmox/config/ca" }}
  - path: /etc/ssh/ca.pem
    content: {{ .Data.public_key }}
  {{ end }}
        EOH
      }

      vault {
        role = "qemu-forgejo-runner"
      }

      identity {
        name = "vault_default"
        ttl  = "15m"
        aud  = ["infrastructure.demophoon.com"]
      }
    }

    task "server" {
      driver = "qemu"
      config {
        image_path  = "${NOMAD_ALLOC_DIR}/data/noble-server-cloudimg-amd64.img"
        accelerator = "kvm"
        guest_agent = true
        args = [
          "-enable-kvm",
          "-cpu", "host",
          "-drive", "file=${NOMAD_ALLOC_DIR}/data/seed.iso,index=1,media=cdrom",
          "-vnc", "unix:${NOMAD_ALLOC_DIR}/vnc.sock",
          #"-netdev", "bridge,id=net0,br=br0",
          #"-device", "virtio-net-pci,netdev=net0",
        ]
      }
      resources {
        cpu    = 1000
        memory = 2048
      }
    }

    task "novnc" {
      driver = "docker"
      lifecycle {
        hook    = "poststart"
        sidecar = true
      }
      config {
        image      = "theasp/novnc:latest"
        entrypoint = ["/usr/bin/websockify"]
        args = [
          "--web", "/usr/share/novnc",
          "${NOMAD_PORT_novnc}",
          "--unix-target", "/alloc/vnc.sock",
        ]
        ports = ["novnc"]
      }
      service {
        name     = "runner-vnc"
        port     = "novnc"
        provider = "consul"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.runner-vnc-${NOMAD_ALLOC_INDEX}.rule=Host(`vnc.internal.demophoon.com`)",
          "traefik.http.services.runner-vnc-${NOMAD_ALLOC_INDEX}.loadbalancer.server.port=${NOMAD_PORT_novnc}",
        ]
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }

  }
}
