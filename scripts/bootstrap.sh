#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_PATH="${BASH_SOURCE[0]-}"
LIB_DIR="${MICROCLOUD_LIB_DIR:-/usr/local/lib/microcloud}"

bootstrap_require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

bootstrap_fetch() {
  local url="$1"

  if bootstrap_require_cmd curl; then
    curl -fsSL "$url"
    return 0
  fi

  if bootstrap_require_cmd wget; then
    wget -qO- "$url"
    return 0
  fi

  echo "missing curl or wget" >&2
  return 1
}

bootstrap_prepare_libs() {
  local repo_ref="${MICROCLOUD_REF:-main}"
  local repo_raw_base="${MICROCLOUD_RAW_BASE:-https://raw.githubusercontent.com/Oogy/microcloud}"
  local tmp_dir

  if [ -f "$LIB_DIR/k0s.sh" ] && [ -f "$LIB_DIR/argocd.sh" ]; then
    return 0
  fi

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  bootstrap_fetch "${repo_raw_base}/${repo_ref}/scripts/lib/k0s.sh" >"$tmp_dir/k0s.sh"
  bootstrap_fetch "${repo_raw_base}/${repo_ref}/scripts/lib/argocd.sh" >"$tmp_dir/argocd.sh"

  install -d "$LIB_DIR"
  install -m 0644 "$tmp_dir/k0s.sh" "$LIB_DIR/k0s.sh"
  install -m 0644 "$tmp_dir/argocd.sh" "$LIB_DIR/argocd.sh"
}

bootstrap_prepare_libs

. "$LIB_DIR/k0s.sh"
. "$LIB_DIR/argocd.sh"

main() {
  k0s_bootstrap "$@"
  argocd_install_manifest "$@"
}

main "$@"
