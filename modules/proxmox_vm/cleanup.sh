#!/usr/bin/env bash

node=${1:-No node name passed into script}

node_id=$(nomad node status | grep "$node" | awk '{print $1}')

is_vault_active() {
  node=${1:-Node must be passed into function}
  consul catalog services -node="${node}" -tags | grep vault | grep -q active
}

if is_vault_active "$node"; then
  echo "!! Vault is active on $node"
  echo "!!"
  echo "!! Seal the vault on this node before continuing."
  exit 1
fi

if [ -n "$node_id" ]; then
  echo "Draining node..."
  nomad node drain -enable -deadline 5m -yes "$node_id"
  echo "Node drained."

  echo "Leaving consul cluster..."
  consul force-leave "$node"
  echo "Left consul cluster."
else
  echo "Nothing to do."
fi
