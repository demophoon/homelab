#!/usr/bin/env sh
set -eu

ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
RUNNER_VERSION=$(curl -X GET https://data.forgejo.org/api/v1/repos/forgejo/runner/releases/latest | jq .name -r | cut -c 2-)
FORGEJO_URL="https://code.forgejo.org/forgejo/runner/releases/download/v${RUNNER_VERSION}/forgejo-runner-${RUNNER_VERSION}-linux-${ARCH}"

wget -O /tmp/forgejo-runner "$FORGEJO_URL"
chmod +x /tmp/forgejo-runner
install -m 0755 /tmp/forgejo-runner /usr/local/bin/forgejo-runner
