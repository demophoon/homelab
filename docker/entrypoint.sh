#!/bin/sh

set -e

tf_workspace_dir="/local/repo/workspaces/${NOMAD_META_APPLY_WORKSPACE}"
flags="-chdir=${tf_workspace_dir}"

echo "Applying Terraform configuration in ${tf_workspace_dir}..."

init() {
  mkdir -p /local/repo
  git clone "${GIT_REPO_URL}" "/local/repo"
  terraform "${flags}" init -upgrade
}

case "$1" in
  "plan")
    init
    terraform "${flags}" plan
    ;;
  "apply")
    init
    terraform "${flags}" apply -auto-approve
    ;;
  *)
    echo "Unknown command: $1"
    exit 1
esac
