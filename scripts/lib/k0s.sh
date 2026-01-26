#!/usr/bin/env bash

k0s_require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

k0s_run_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

k0s_fetch() {
  local url="$1"

  if k0s_require_cmd curl; then
    curl -sSLf "$url"
    return
  fi

  if k0s_require_cmd wget; then
    wget -qO- "$url"
    return
  fi

  echo "missing curl or wget" >&2
  return 1
}

k0s_install_binary() {
  local version="${K0S_VERSION:-}"
  local install_dir="${K0S_INSTALL_DIR:-/usr/local/bin}"

  if k0s_require_cmd k0s; then
    return 0
  fi

  if [ -n "$version" ]; then
    k0s_fetch https://get.k0s.sh | k0s_run_sudo env K0S_VERSION="$version" K0S_INSTALL_DIR="$install_dir" sh
    return
  fi

  k0s_fetch https://get.k0s.sh | k0s_run_sudo env K0S_INSTALL_DIR="$install_dir" sh
}

k0s_bootstrap() {
  k0s_install_binary
  if k0s_run_sudo systemctl is-active --quiet k0scontroller; then
    return 0
  fi

  if [ -f /etc/systemd/system/k0scontroller.service ] || k0s_run_sudo k0s status >/dev/null 2>&1; then
    k0s_run_sudo k0s start
    return 0
  fi

  k0s_run_sudo k0s install controller --single --enable-worker
  k0s_run_sudo k0s start
}

k0s_stop() {
  k0s_run_sudo k0s stop || true
}

k0s_reset() {
  k0s_stop
  k0s_run_sudo k0s reset --force
}
