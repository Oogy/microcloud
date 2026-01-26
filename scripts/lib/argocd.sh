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

argocd_repo_url() {
  if [ -n "${ARGOCD_REPO_URL:-}" ]; then
    echo "$ARGOCD_REPO_URL"
    return 0
  fi

  if command -v git >/dev/null 2>&1; then
    git -C "${ARGOCD_REPO_PATH:-.}" config --get remote.origin.url 2>/dev/null || true
  fi
}

argocd_apply_applicationset() {
  local serial="${1:-}"
  local repo_url
  local revision="${ARGOCD_REVISION:-HEAD}"
  local namespace="${ARGOCD_NAMESPACE:-argocd}"
  local appset_name

  if [ -z "$serial" ]; then
    echo "usage: argocd_apply_applicationset <device-serial>" >&2
    return 2
  fi

  if ! argocd_require_cmd k0s; then
    echo "missing k0s" >&2
    return 1
  fi

  repo_url="$(argocd_repo_url)"
  if [ -z "$repo_url" ]; then
    echo "missing ARGOCD_REPO_URL and no git remote origin found" >&2
    return 1
  fi

  appset_name="${ARGOCD_APPSET_NAME:-host-${serial}}"

  k0s kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: ${appset_name}
  namespace: ${namespace}
spec:
  goTemplate: true
  generators:
    - matrix:
        generators:
          - git:
              repoURL: ${repo_url}
              revision: ${revision}
              files:
                - path: hosts/${serial}.yaml
          - list:
              elementsYaml: |
                {{ toYaml .apps }}
  template:
    metadata:
      name: "{{ .name }}-${serial}"
    spec:
      project: default
      source:
        repoURL: ${repo_url}
        targetRevision: ${revision}
        path: apps/{{ .name }}
        helm:
          values: |
            {{- with .values }}
            {{ toYaml . }}
            {{- end }}
      destination:
        server: https://kubernetes.default.svc
        namespace: "{{ .name }}"
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
EOF
}
