#!/usr/bin/env bash
set -euo pipefail

ARGOCD_MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

ensure_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "error: run as root" >&2
    exit 1
  fi
}

try_run() {
  "$@" >/dev/null 2>&1 || true
}

stop_disable_unit() {
  local unit="$1"
  try_run systemctl disable --now "${unit}"
}

remove_unit() {
  local unit="$1"
  rm -f "/etc/systemd/system/${unit}"
}

remove_microcloud_units() {
  stop_disable_unit microcloud-argocd.service
  stop_disable_unit microcloud-k8s.service
  stop_disable_unit microcloud-host.service
  stop_disable_unit microcloud-argocd.target
  stop_disable_unit microcloud-k8s.target
  stop_disable_unit microcloud-host.target

  remove_unit microcloud-argocd.service
  remove_unit microcloud-k8s.service
  remove_unit microcloud-host.service
  remove_unit microcloud-argocd.target
  remove_unit microcloud-k8s.target
  remove_unit microcloud-host.target
  systemctl daemon-reload
}

remove_done_files() {
  rm -f /var/lib/microcloud/argocd.done
  rm -f /var/lib/microcloud/k8s.done
  rm -f /var/lib/microcloud/host.done
  rmdir /var/lib/microcloud 2>/dev/null || true
}

remove_argocd() {
  if command -v k0s >/dev/null 2>&1; then
    try_run k0s kubectl delete -f "${ARGOCD_MANIFEST_URL}"
    try_run k0s kubectl delete -n argocd -f "${ARGOCD_MANIFEST_URL}"
    try_run k0s kubectl delete namespace argocd
  fi
}

stop_and_reset_k0s() {
  if command -v k0s >/dev/null 2>&1; then
    try_run systemctl disable --now k0scontroller.service
    try_run systemctl disable --now k0sworker.service
    try_run k0s stop
    try_run k0s reset --force
  fi
}

remove_k0s_data() {
  rm -rf /var/lib/k0s /etc/k0s /var/log/k0s
}

remove_binaries() {
  rm -f /usr/local/bin/microcloud-host
  rm -f /usr/local/bin/microcloud-k8s
  rm -f /usr/local/bin/microcloud-argocd
  rm -f /usr/local/bin/k0s
}

main() {
  ensure_root
  remove_argocd
  stop_and_reset_k0s
  remove_microcloud_units
  remove_done_files
  remove_k0s_data
  remove_binaries
}

main "$@"
