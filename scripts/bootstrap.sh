#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/lib/k0s.sh"
. "$SCRIPT_DIR/lib/argocd.sh"

main() {
  k0s_bootstrap "$@"
  argocd_install_manifest "$@"
}

main "$@"
