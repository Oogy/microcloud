#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/lib/k0s.sh"
. "$SCRIPT_DIR/lib/argocd.sh"

run_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_systemd_unit() {
  local unit_src="$SCRIPT_DIR/systemd/microcloud-bootstrap.service"
  local unit_dst="/etc/systemd/system/microcloud-bootstrap.service"

  run_sudo install -m 0644 "$unit_src" "$unit_dst"
  run_sudo systemctl daemon-reload
  run_sudo systemctl enable microcloud-bootstrap.service
}

install_bootstrap_script() {
  local src="$SCRIPT_DIR/bootstrap.sh"
  local dst="/usr/local/bin/microcloud-bootstrap"

  run_sudo install -m 0755 "$src" "$dst"
}

main() {
  local run_now="no"

  if [ "${1:-}" = "--now" ]; then
    run_now="yes"
  fi

  k0s_install_binary "$@"
  install_bootstrap_script
  install_systemd_unit

  if [ "$run_now" = "yes" ]; then
    "$SCRIPT_DIR/bootstrap.sh"
  fi
}

main "$@"
