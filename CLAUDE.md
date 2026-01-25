# CLAUDE.md

Guidance for Claude Code when working with this repository.

## Project Overview

microcloud orchestrates a baremetal local cloud. Every machine runs its own single-node k0s cluster with ArgoCD managing workloads.

## Key Principles

1. **Every node is its own cluster** - No multi-node clusters, each machine independent
2. **ArgoCD manages all workloads** - entrypointd bootstraps, ArgoCD reconciles app contents
3. **Privileged pods for host access** - GPU drivers, NFS server, etc. installed via chroot
4. **Helm for deployments** - Prefer Helm over raw manifests or Kustomize
5. **KISS** - Keep it simple

## Repository Structure

```
microcloud/
├── apps/
│   ├── base/                  # Helm chart
│   └── nfs/                   # Helm chart
├── bootstrap/
│   ├── install.sh
│   ├── argocd.sh
│   └── k0s.sh
├── docs/
│   └── hosts/
│       └── <serial>.yaml      # apps + values (GitHub Pages)
├── entrypointd/
│   ├── entrypointd.sh
│   └── entrypointd.service
```

## entrypointd Flow

```
get_serial() → fetch_host() → generate_applications() → install_k0s() → install_argocd() → apply_applications()
```

## Hosts

Host files list apps directly (served via GitHub Pages):

```yaml
# docs/hosts/S7NRCX04S394286.yaml
apps:
  - base
  - nfs
values:
  hostname: rig1
  nfs_export_path: /data
```

## Adding a Machine

1. Get serial: `cat /sys/class/dmi/id/product_serial`
2. Create `docs/hosts/<serial>.yaml` with apps + values
3. Commit and push
4. Install entrypointd

## Updating Apps

After changing apps list, re-run entrypointd:
```bash
sudo systemctl start entrypointd
```

## Apps vs Groups

**Apps** are regular Helm charts that deploy workloads directly (Jobs, ConfigMaps, Deployments, etc.).

**Groups** are app-of-apps Helm charts that template ArgoCD Application manifests. They bundle multiple apps for a role while maintaining individual ArgoCD visibility.

```
apps/
├── base/                  # App - batch jobs for all nodes
├── nfs/                   # App - NFS server setup
└── storage-node/          # Group - deploys base + nfs + monitoring
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        └── applications.yaml   # Renders ArgoCD Applications
```

Group template pattern:
```yaml
# apps/<group>/templates/applications.yaml
{{- range .Values.apps }}
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ . }}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/oogy/microcloud.git
    targetRevision: HEAD
    path: apps/{{ . }}
    helm:
      values: |
        {{- index $.Values "values" | toYaml | nindent 8 }}
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
{{- end }}
```

Host files can mix apps and groups:
```yaml
apps:
  - base           # individual app
  - storage-node   # group (expands to multiple ArgoCD apps)
values:
  hostname: rig1
  nfs_export_path: /data
```

## Privileged Pod Pattern

For host modifications:

```yaml
spec:
  hostPID: true
  hostNetwork: true
  containers:
  - securityContext:
      privileged: true
    volumeMounts:
    - name: host
      mountPath: /host
    command: ["chroot", "/host", "..."]
  volumes:
  - name: host
    hostPath:
      path: /
```
