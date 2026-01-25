#!/bin/bash
set -euo pipefail

# entrypointd - Bootstrap k0s + ArgoCD

readonly RAW_URL="https://raw.githubusercontent.com/Oogy/microcloud/main"
readonly PAGES_URL="https://oogy.github.io/microcloud"

log() {
    echo "[entrypointd] $1" >&2
}

get_serial() {
    cat /sys/class/dmi/id/product_serial | tr -d '[:space:]'
}

fetch_host() {
    local serial="$1"
    curl -fsSL "${PAGES_URL}/hosts/${serial}.yaml"
}

install_k0s() {
    if command -v k0s &>/dev/null; then
        log "k0s already installed"
        return 0
    fi
    log "Installing k0s..."
    curl -fsSL "${RAW_URL}/bootstrap/k0s.sh" | bash
}

install_argocd() {
    if kubectl get namespace argocd &>/dev/null; then
        log "ArgoCD already installed"
        return 0
    fi
    log "Installing ArgoCD..."
    curl -fsSL "${RAW_URL}/bootstrap/argocd.sh" | bash
}

generate_applications() {
    local host_yaml="$1"

    local apps=$(echo "$host_yaml" | grep -A100 '^apps:' | grep '^ *- ' | sed 's/^ *- //')

    for app in $apps; do
        log "Generating Application: ${app}"
        cat <<EOF
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${app}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Oogy/microcloud
    targetRevision: HEAD
    path: apps/${app}
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
    done
}

apply_applications() {
    local serial="$1"

    log "Fetching host file for ${serial}..."
    local host_yaml=$(fetch_host "$serial") || {
        log "No host file found for ${serial}, exiting"
        exit 0
    }

    log "Generating applications..."
    local manifests=$(generate_applications "$host_yaml")

    log "Applying applications..."
    echo "$manifests" | kubectl apply -f -
}

main() {
    local serial

    serial=$(get_serial)
    log "Serial: ${serial}"

    install_k0s
    install_argocd
    apply_applications "${serial}"

    log "Bootstrap complete, ArgoCD takes over"
}

main "$@"
