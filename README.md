# microcloud

Baremetal local cloud orchestrator. Every machine runs its own k0s + ArgoCD cluster.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Oogy/microcloud/main/bootstrap/install.sh | sudo bash
```

To bootstrap immediately:
```bash
sudo systemctl start entrypointd
```

## Structure

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

## How It Works

1. **entrypointd** gets serial, fetches host file from GitHub Pages
2. **entrypointd** generates Application manifests from apps list
3. **entrypointd** installs k0s + ArgoCD, applies Applications
4. **ArgoCD** syncs apps

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
4. Install entrypointd on the machine

## Updating Apps

After changing a host's apps, re-run entrypointd:
```bash
sudo systemctl start entrypointd
```
