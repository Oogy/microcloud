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

  if [ -f "$LIB_DIR/k0s.sh" ] && [ -f "$LIB_DIR/argocd.sh" ] && [ -f "$LIB_DIR/system.sh" ]; then
    return 0
  fi

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  bootstrap_fetch "${repo_raw_base}/${repo_ref}/scripts/lib/k0s.sh" >"$tmp_dir/k0s.sh"
  bootstrap_fetch "${repo_raw_base}/${repo_ref}/scripts/lib/argocd.sh" >"$tmp_dir/argocd.sh"
  bootstrap_fetch "${repo_raw_base}/${repo_ref}/scripts/lib/system.sh" >"$tmp_dir/system.sh"

  install -d "$LIB_DIR"
  install -m 0644 "$tmp_dir/k0s.sh" "$LIB_DIR/k0s.sh"
  install -m 0644 "$tmp_dir/argocd.sh" "$LIB_DIR/argocd.sh"
  install -m 0644 "$tmp_dir/system.sh" "$LIB_DIR/system.sh"
}

bootstrap_prepare_libs

. "$LIB_DIR/k0s.sh"
. "$LIB_DIR/argocd.sh"
. "$LIB_DIR/system.sh"

bootstrap_wait_for_k0s() {
  local tries="${K0S_READY_TRIES:-60}"
  local delay="${K0S_READY_DELAY:-2}"
  local i

  for i in $(seq 1 "$tries"); do
    if k0s status 2>/dev/null | grep -q "State: Running"; then
      return 0
    fi
    sleep "$delay"
  done

  echo "k0s did not report State: Running after $((tries * delay))s" >&2
  return 1
}

main() {
  if system_is_raspberry_pi; then
    system_enable_cgroup_memory_if_needed
    case "$?" in
      0) ;;
      10)
        system_schedule_reboot
        return 0
        ;;
      *)
        return 1
        ;;
    esac
  fi

  k0s_bootstrap "$@"
  bootstrap_wait_for_k0s
  argocd_install_manifest "$@"
}

main "$@"
