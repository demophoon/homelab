#!/usr/bin/env sh
set -eu

ARCH=$( [ "$(uname -m)" = "aarch64" ] && echo arm64 || echo amd64 )
curl -L -o /tmp/cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-${ARCH}-v1.0.0.tgz"
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz
