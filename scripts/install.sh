#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]-}"
SCRIPT_DIR=""
TMP_DIR=""

install_require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_prepare_sources() {
  if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    return 0
  fi

  if ! install_require_cmd git; then
    echo "missing git" >&2
    return 1
  fi

  TMP_DIR="$(mktemp -d)"
  trap 'if [ -n "${TMP_DIR:-}" ]; then rm -rf "$TMP_DIR"; fi' EXIT

  git clone --depth 1 --branch "${MICROCLOUD_REF:-main}" "${MICROCLOUD_REPO:-https://github.com/Oogy/microcloud.git}" "$TMP_DIR/repo" >/dev/null

  SCRIPT_DIR="$TMP_DIR/repo/scripts"
}

install_prepare_sources

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

install_libs() {
  local lib_dir="${MICROCLOUD_LIB_DIR:-/usr/local/lib/microcloud}"

  run_sudo install -d "$lib_dir"
  run_sudo install -m 0644 "$SCRIPT_DIR/lib/k0s.sh" "$lib_dir/k0s.sh"
  run_sudo install -m 0644 "$SCRIPT_DIR/lib/argocd.sh" "$lib_dir/argocd.sh"
}

main() {
  local run_now="no"

  if [ "${1:-}" = "--now" ]; then
    run_now="yes"
  fi

  k0s_install_binary "$@"
  install_libs
  install_bootstrap_script
  install_systemd_unit

  if [ "$run_now" = "yes" ]; then
    run_sudo /usr/local/bin/microcloud-bootstrap
  fi
}

main "$@"
