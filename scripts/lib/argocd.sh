#!/usr/bin/env bash

argocd_require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

argocd_install_manifest() {
  local manifest_url="${ARGOCD_MANIFEST_URL:-https://github.com/argoproj/argo-cd/blob/master/manifests%2Finstall.yaml}"

  if ! argocd_require_cmd k0s; then
    echo "missing k0s" >&2
    return 1
  fi

  k0s kubectl apply -f "$manifest_url"
}
