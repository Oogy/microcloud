#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]-}"
SCRIPT_DIR=""
TMP_DIR=""

install_require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_fetch() {
  local url="$1"

  if install_require_cmd curl; then
    curl -fsSL "$url"
    return 0
  fi

  if install_require_cmd wget; then
    wget -qO- "$url"
    return 0
  fi

  echo "missing curl or wget" >&2
  return 1
}

install_prepare_sources() {
  local repo_ref="${MICROCLOUD_REF:-main}"
  local repo_raw_base="${MICROCLOUD_RAW_BASE:-https://raw.githubusercontent.com/Oogy/microcloud}"
  if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    return 0
  fi

  TMP_DIR="$(mktemp -d)"
  trap 'if [ -n "${TMP_DIR:-}" ]; then rm -rf "$TMP_DIR"; fi' EXIT

  install_fetch "${repo_raw_base}/${repo_ref}/scripts/lib/k0s.sh" >"$TMP_DIR/k0s.sh"
  install_fetch "${repo_raw_base}/${repo_ref}/scripts/lib/argocd.sh" >"$TMP_DIR/argocd.sh"
  install_fetch "${repo_raw_base}/${repo_ref}/scripts/bootstrap.sh" >"$TMP_DIR/bootstrap.sh"
  install_fetch "${repo_raw_base}/${repo_ref}/scripts/systemd/microcloud-bootstrap.service" >"$TMP_DIR/microcloud-bootstrap.service"

  SCRIPT_DIR="$TMP_DIR"
}

install_prepare_sources

. "$SCRIPT_DIR/k0s.sh"
. "$SCRIPT_DIR/argocd.sh"

run_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_systemd_unit() {
  local unit_src="$SCRIPT_DIR/microcloud-bootstrap.service"
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
  run_sudo install -m 0644 "$SCRIPT_DIR/k0s.sh" "$lib_dir/k0s.sh"
  run_sudo install -m 0644 "$SCRIPT_DIR/argocd.sh" "$lib_dir/argocd.sh"
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
