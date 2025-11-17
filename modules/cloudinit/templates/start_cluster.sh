#!/usr/bin/env bash
set -x
set -o pipefail

%{if include_media}
export mount_flags="rw,relatime,vers=4.2,rsize=65536,wsize=65536,hard,timeo=600,retrans=2,sec=sys,local_lock=none"
export mount_srv="truenas.service.consul.demophoon.com"
export mount_srv="192.168.1.163"

mount_pv() {
  if [ -e /dev/sda1 ]; then
    mkdir -p /mnt/${pv_name}
    mount -t ext4 /dev/sda1 /mnt/${pv_name}
  fi
}

mount_nfs() {
  mkdir -p /mnt/nfs
  mkdir -p /mnt/media
  mount -t nfs -o "$mount_flags" "$mount_srv:/mnt/dank0/andromeda" /mnt/nfs
  mount -t nfs -o "$mount_flags" "$mount_srv:/mnt/dank0/media" /mnt/media

  mount_pv
}
%{endif}

rm -f /etc/systemd/resolved.conf.d/DigitalOcean.conf

is_consul_connected() {
  consul members
}

connect_to_consul() {
  echo "starting consul..."
  # We need to put consul into "starting" state so that we can issue join commands to it.
  systemctl start consul &
  sleep 3
  systemctl restart systemd-resolved &
  sleep 3

  join_addrs=$(tailscale status --json | jq -r '.Peer | to_entries [].value.HostName')
  joined=0

  set +x
  for join_addr in $${join_addrs}; do
    if consul join "$${join_addr%%:*}"; then
      joined=1
      break
    fi
  done
  set -x

  if [ $joined -eq 0 ]; then
    echo "Unable to join cluster. \nAttempted:\n$${join_addrs}"
    exit 1
  fi
}

wait_for_service() {
  service=$1
  for i in {0..30}; do
    sleep 1
    if [ "$(dig +short -t srv $service.service.consul.demophoon.com.)" ]; then
      echo "consul successfully connected"
      break
    else
      echo "waiting for $service..."
    fi
  done

}
wait_for_consul() {
  wait_for_service "consul"
}
wait_for_vault() {
  wait_for_service "vault"
}

# ==================================
# Retrieve provisioning secrets
# Requires AppRole or Token on disk
with_vault() {
  export VAULT_ADDR="https://active.vault.service.consul.demophoon.com:8200/"
  if [ -f /root/.approle_token ]; then
    export VAULT_TOKEN=$(cat /root/.approle_token)
  else
    for i in {0..30}; do
      export VAULT_TOKEN=$${VAULT_TOKEN:-$(vault write -field token auth/approle/login role_id="${role_id}" secret_id="${secret_id}")}
      if [ -z "$${VAULT_TOKEN}" ]; then
        sleep 10
      else
        echo $VAULT_TOKEN > /root/.approle_token
        break
      fi
    done
  fi

  if [ -z "$${VAULT_TOKEN}" ]; then
    echo "Vault unable to retrieve token"
    exit 1
  fi
}

write_ssh_host_key() {(with_vault
  vault write -field=signed_key proxmox/sign/host \
    cert_type=host \
    public_key=@/etc/ssh/ssh_host_rsa_key.pub > /etc/ssh/ssh_host_rsa_key-cert.pub
)}

write_vault_certificate() {(with_vault
  mkdir -p /opt/vault/certs
  if [ ! -s /opt/vault/certs/issued.json ]; then
    vault write -format=json pki/issue/backplane \
      common_name=${hostname} \
      alt_names=vault.service.consul.demophoon.com,active.vault.service.consul.demophoon.com,standby.vault.service.consul.demophoon.com > /opt/vault/certs/issued.json
  fi
  cat /opt/vault/certs/issued.json | jq -re .data > /dev/null
  cat /opt/vault/certs/issued.json | jq -r .data.certificate > /opt/vault/certs/cert.pem
  cat /opt/vault/certs/issued.json | jq -r .data.private_key > /opt/vault/certs/priv.key
)}

write_consul_certificate() {(with_vault
  mkdir -p /opt/consul/certs
  if [ ! -s /opt/consul/certs/issued.json ]; then
    vault write -format=json pki/issue/backplane \
      common_name=${hostname} \
      alt_names=consul.service.consul.demophoon.com > /opt/consul/certs/issued.json
  fi
  cat /opt/consul/certs/issued.json | jq -re .data > /dev/null
  cat /opt/consul/certs/issued.json | jq -r .data.certificate > /opt/consul/certs/cert.pem
  cat /opt/consul/certs/issued.json | jq -r .data.private_key > /opt/consul/certs/priv.key
)}

write_nomad_certificate() {(with_vault
  mkdir -p /opt/nomad/certs
  if [ ! -s /opt/nomad/certs/issued.json ]; then
    vault write -format=json pki/issue/backplane \
      common_name=${hostname} \
      alt_names=nomad.service.consul.demophoon.com > /opt/nomad/certs/issued.json
  fi
  cat /opt/nomad/certs/issued.json | jq -re .data > /dev/null
  cat /opt/nomad/certs/issued.json | jq -r .data.certificate > /opt/nomad/certs/cert.pem
  cat /opt/nomad/certs/issued.json | jq -r .data.private_key > /opt/nomad/certs/priv.key
)}

main() {
  if ! is_consul_connected; then
    connect_to_consul
    wait_for_consul
    wait_for_vault
  fi

  write_ssh_host_key
  systemctl restart ssh

  write_vault_certificate
  write_consul_certificate
  write_nomad_certificate
%{if include_media}  mount_nfs%{endif}
%{if is_server}
  systemctl restart vault
%{ else }
  systemctl stop vault
%{ endif }
  systemctl restart nomad
  systemctl restart dnsmasq
}

main
