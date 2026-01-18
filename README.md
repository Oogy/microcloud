# microcloud

Infrastructure and orchestration for a baremetal local cloud.

## Architecture

microcloud uses PXE boot to provision bare metal machines with a common bootable image. Each machine queries its host-specific inventory to determine which portable services to attach.

```
                    ┌─────────────────┐
                    │   microcloud    │
                    │  (orchestrator) │
                    ├─────────────────┤
                    │ - inventory     │
                    │ - Makefile      │
                    │ - docs (Pages)  │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
         ▼                   ▼                   ▼
   ┌──────────┐       ┌─────────────┐    ┌────────────────┐
   │  booter  │       │ entrypointd │    │ dnsmasq-portable│
   │ (image)  │       │ (portable)  │    │   (portable)   │
   └──────────┘       └─────────────┘    └────────────────┘
```

## Components

| Repo | Description |
|------|-------------|
| [booter](https://github.com/Oogy/booter) | Minimally bootable mkosi machine image |
| [entrypointd-portable](https://github.com/Oogy/entrypointd-portable) | Portable service manager, fetches inventory |
| [dnsmasq-portable](https://github.com/Oogy/dnsmasq-portable) | PXE/TFTP server in proxy-DHCP mode |

## Boot Flow

1. **PXE Boot**: Machine network boots, dnsmasq-portable (on another machine) serves the booter image via TFTP
2. **Kernel Boot**: booter starts with `systemd.pull=` kernel parameter that triggers systemd-import-generator
3. **entrypointd Fetch**: systemd-import-generator downloads entrypointd-portable from GitHub releases at boot
4. **Inventory Check**: entrypointd reads `/sys/class/dmi/id/product_serial` and fetches `oogy.github.io/microcloud/inventory/<serial>`
5. **Portable Management**: entrypointd downloads and attaches portables listed in inventory via `portablectl attach`
6. **Continuous Loop**: entrypointd checks every 60s for updates, self-updates first if a new version is available

## Bootstrap

Create all GitHub repos with the Makefile (uses `gh` CLI):

```bash
make          # Create all repos and enable Pages
make repos    # Just create repos
make pages    # Just enable GitHub Pages on microcloud
make booter   # Create single repo
```

## Inventory

Machine-specific configuration lives in `docs/inventory/<serial>`. Each file contains newline-separated portable service names to attach:

```
dnsmasq_0.0.1
```

Format: `<name>_<version>` where:
- `name` maps to repo `<name>-portable` (e.g., `dnsmasq` → `dnsmasq-portable`)
- `version` maps to release tag `v<version>` (e.g., `0.0.1` → `v0.0.1`)

Served via GitHub Pages at `oogy.github.io/microcloud/inventory/<serial>`.

### Adding a Machine

1. Get serial: `cat /sys/class/dmi/id/product_serial`
2. Create `docs/inventory/<serial>` with desired portables
3. Commit and push - GitHub Pages auto-deploys

## Creating Releases

Each component repo has GitHub Actions that build on tag push:

```bash
cd <repo>
git tag v0.0.1
git push origin v0.0.1
```

This triggers the workflow which:
1. Builds the image with mkosi
2. Creates a GitHub release with the `.raw.xz` artifact
3. Creates a stable filename (e.g., `booter.raw.xz`) for `/latest/download/` URLs

## Technologies

- **mkosi** - systemd's image builder for reproducible OS images
- **systemd portables** - lightweight service isolation without containers
- **systemd.pull=** - kernel parameter (systemd 257+) for downloading portables at boot via systemd-import-generator
- **importctl/portablectl** - systemd tools for managing portable images
- **PXE/TFTP** - network boot for bare metal provisioning
- **GitHub Pages** - serves machine inventory
- **GitHub Actions** - builds images on tag push
- **gh CLI** - GitHub CLI for repo management (replaces Terraform)
