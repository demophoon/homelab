#!/usr/bin/env bash

# This script provides helper functions for logging into demophoon's infrastructure via SSH.
# This includes helpers for downloading the vault binary if it is not already installed.

is_vault_installed() {
    command -v vault >/dev/null 2>&1
}

is_vault_downloaded() {
    [[ -x "${HOME}/.local/bin/vault" ]]
}

download_vault() {
  if is_vault_installed || is_vault_downloaded; then
    return 0
  fi

  local vault_version="1.19.5"
  local os_type
  local arch_type
  local download_url
  local temp_dir
  local vault_zip

  os_type=$(uname | tr '[:upper:]' '[:lower:]')
  arch_type=$(uname -m)

  case "$arch_type" in
    x86_64) arch_type="amd64" ;;
    aarch64) arch_type="arm64" ;;
    *) echo "Unsupported architecture: $arch_type" >&2; return 1 ;;
  esac

  download_url="https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_${os_type}_${arch_type}.zip"
  temp_dir=$(mktemp -d)
  vault_zip="${temp_dir}/vault.zip"

  curl -o "$vault_zip" "$download_url"

  unzip -q "$vault_zip" -d "$temp_dir"

  sudo mv "${temp_dir}/vault" "${HOME}/.local/bin/"
  sudo chmod +x "${HOME}/.local/bin/vault"

  rm -rf "${temp_dir:?}"
}

get_ssh_key() {
  for key in "${HOME}"/.ssh/*.pub; do
    case "$key" in
      *-cert.pub)
        continue
        ;;
      *.pub)
        echo "$key"
        return 0
        ;;
    esac
  done

  return 1
}

sign_key() {
  local vault_addr="https://vault-ui.internal.demophoon.com"

  if ! vault token lookup -format=yaml | grep -q 'id: hvs.'; then
    VAULT_ADDR="${vault_addr}" vault login -method=oidc -no-print role=ssh-user
  fi

  local key
  key=$(get_ssh_key)
  echo "${key}"
  cert=${key/.pub/-cert.pub}
  if [[ -z "$key" ]]; then
    echo "No SSH public key found in ~/.ssh/"
    exit 1
  fi
  VAULT_ADDR="${vault_addr}" vault write -field=signed_key proxmox/sign/ssh-user public_key=@"${key}" ttl="30m" > "${cert}"
  ssh-keygen -L -f "${cert}" | grep Valid: | xargs

  local ca
  ca=$(VAULT_ADDR="${vault_addr}" vault read -field=public_key "proxmox/config/ca")

  if ! grep -Fq "@cert-authority * ${ca}" "${HOME}/.ssh/known_hosts"; then
    echo "@cert-authority * ${ca}" >> "${HOME}/.ssh/known_hosts"
    echo added CA to known_hosts
  fi
}

main() {
  download_vault
  sign_key
}

main
