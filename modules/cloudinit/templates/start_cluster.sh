#!/usr/bin/env bash
set -x
set -o pipefail

%{if do_pv}
mount_pv() {
  if [ -e /dev/disk/by-label/${pv_name} ]; then
    mkdir -p /mnt/${pv_name}
    mount -t ext4 /dev/disk/by-label/${pv_name} /mnt/${pv_name}
  fi
}
%{endif}

%{if include_media}
export mount_flags="rw,relatime,vers=4.2,rsize=65536,wsize=65536,hard,timeo=600,retrans=2,sec=sys,local_lock=none"
export mount_srv="truenas.service.consul.demophoon.com"
export mount_srv="${truenas_ip}"

mount_pv() {
  if [ -e /dev/sda1 ]; then
    mkdir -p /mnt/${pv_name}
    mount -t ext4 /dev/sda1 /mnt/${pv_name}
  elif [ -e /dev/sda ]; then
    parted -a none /dev/sda --script 'mklabel gpt mkpart ${pv_name} ext4 0 100% resizepart 1 100% quit'
    mkfs.ext4 /dev/sda1
    mount_pv
  fi
}

install_miren() {
  miren_tmp="$(mktemp -d)"
  curl -Lo "$miren_tmp/miren.zip" https://api.miren.cloud/assets/release/miren/latest/miren-linux-amd64.zip
  unzip "$miren_tmp/miren.zip" -d "$miren_tmp"
  mv "$miren_tmp/miren" /usr/local/bin/miren
}

mount_nfs() {
  mkdir -p /mnt/nfs
  mkdir -p /mnt/media
  mount -t nfs -o "$mount_flags" "$mount_srv:/mnt/dank0/andromeda" /mnt/nfs
  mount -t nfs -o "$mount_flags" "$mount_srv:/mnt/dank0/media" /mnt/media

  mount_pv
}
%{endif}

start_tailscale_services() {
  tailscale serve --service=svc:nomad  --tcp=4646 tcp://${hostname}.blue-bowfin.ts.net:4646

  tailscale serve --service=svc:consul --tcp=8300 tcp://${hostname}.blue-bowfin.ts.net:8300
  tailscale serve --service=svc:consul --tcp=8301 tcp://${hostname}.blue-bowfin.ts.net:8301
  tailscale serve --service=svc:consul --tcp=8302 tcp://${hostname}.blue-bowfin.ts.net:8302
  tailscale serve --service=svc:consul --tcp=8501 tcp://${hostname}.blue-bowfin.ts.net:8501

  tailscale serve --service=svc:internal --tcp=80  localhost:80
  tailscale serve --service=svc:internal --tcp=443 localhost:443
}

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

  join_addrs=$(tailscale status --json | jq -r '.Peer | to_entries [].value | select( [ .Tags // [] | contains(["tag:consul-server"]) ] | any ) | .TailscaleIPs[0]')
  joined=0

  configure_resolved

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

set_ufw_rules() {
  # SSH
  ufw allow 22/tcp
  ufw allow 2222/tcp

  # Http(s)
  ufw allow 80/tcp
  ufw allow 443/tcp

  # Valheim
  ufw allow 2456/udp
  ufw allow 2457/udp
  ufw allow 2458/udp

  # Factorio
  ufw allow 34197/udp
  ufw allow 34197/tcp
}

configure_resolved() {
  rm /etc/resolv.conf
  echo "nameserver 172.17.0.1" | tee /etc/resolv.conf
  echo "nameserver 127.0.0.1"  | tee /etc/resolv.conf
  systemctl restart systemd-resolved
}

main() {
  set_ufw_rules

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
%{if do_pv}  mount_pv%{endif}
%{if is_server}
  systemctl restart vault
%{ else }
  systemctl stop vault
%{ endif }
  systemctl restart nomad
  systemctl restart dnsmasq

%{if is_server}
  start_tailscale_services
%{ endif }

%{if use_miren}
  systemctl stop nomad
  install_miren
%{endif}
}

main
