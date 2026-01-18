# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

microcloud is the orchestrator for a baremetal local cloud. It manages inventory and infrastructure while the actual images live in separate repos. This repo holds:
- Machine inventory served via GitHub Pages
- Makefile for bootstrapping all GitHub repos

## Repository Structure

```
microcloud/
├── Makefile                # Create/configure GitHub repos via gh CLI
├── CLAUDE.md               # This file
├── README.md               # Project documentation
└── docs/                   # GitHub Pages site (oogy.github.io/microcloud)
    ├── index.html          # Landing page
    └── inventory/          # Machine-specific portable lists
        ├── index.html      # Directory listing
        └── <serial>        # File per machine serial number
```

## Bootstrap Infrastructure

Create all microcloud GitHub repos with `gh` CLI:

```bash
make          # Create all repos and enable Pages
make repos    # Just create repos
make pages    # Just enable GitHub Pages
make booter   # Create single repo
```

The Makefile creates repos idempotently (checks if they exist first).

## Related Repositories

| Repo | Purpose | Artifacts |
|------|---------|-----------|
| [booter](https://github.com/Oogy/booter) | Bootable machine image | `booter.raw.xz` |
| [entrypointd-portable](https://github.com/Oogy/entrypointd-portable) | Service manager, fetches inventory | `entrypointd.raw.xz` |
| [dnsmasq-portable](https://github.com/Oogy/dnsmasq-portable) | PXE/TFTP server | `dnsmasq.raw.xz` |

All repos use GitHub Actions to build on tag push (e.g., `v0.0.1`).

## Inventory Format

Files in `docs/inventory/<serial>` contain newline-separated `<name>_<version>`:

```
dnsmasq_0.0.1
entrypointd_0.0.1
```

- `name` → repo `<name>-portable` (e.g., `dnsmasq` → `dnsmasq-portable`)
- `version` → release tag `v<version>` (e.g., `0.0.1` → `v0.0.1`)
- URL pattern: `https://github.com/Oogy/<name>-portable/releases/download/v<version>/<name>.raw.xz`

### Adding a New Machine

1. Get serial: `cat /sys/class/dmi/id/product_serial`
2. Create `docs/inventory/<serial>` with desired portables
3. Commit and push - GitHub Pages auto-deploys

### Current Machines

- `S7NRCX04S394286` - runs `dnsmasq_0.0.1`

## Complete Boot Flow

1. **PXE Boot**: Machine network boots, receives booter from dnsmasq-portable on PXE server
2. **Kernel Parameter**: booter's kernel has `systemd.pull=raw,portable::https://github.com/Oogy/entrypointd-portable/releases/latest/download/entrypointd.raw.xz`
3. **systemd-import-generator**: At boot, systemd 257+ parses `systemd.pull=` and downloads entrypointd-portable
4. **entrypointd starts**: Reads DMI serial from `/sys/class/dmi/id/product_serial`
5. **Inventory fetch**: Downloads `https://oogy.github.io/microcloud/inventory/<serial>`
6. **Self-update check**: If inventory lists a newer entrypointd version, updates itself first
7. **Portable management**: Downloads and attaches other portables via `importctl pull-raw` and `portablectl attach/reattach`
8. **Continuous loop**: Checks every 60s for inventory changes, 2-minute grace period before updating running services

## Key Technologies

- **mkosi**: systemd's image builder - all repos use `mkosi.conf` + `mkosi.extra/` for customization
- **systemd portables**: Lightweight service isolation via `portablectl attach`
- **systemd.pull=**: Kernel parameter (systemd 257+) triggers systemd-import-generator to download at boot
- **importctl**: Downloads portable images (`importctl pull-raw <url>`)
- **portablectl**: Attaches/detaches portables (`portablectl attach/reattach/detach`)
- **GitHub Actions**: `.github/workflows/build.yaml` in each repo builds on tag push
- **GitHub Pages**: Serves inventory from `/docs` folder

## Creating Releases

In any component repo:

```bash
git tag v0.0.1
git push origin v0.0.1
```

The workflow:
1. Runs `mkosi` to build the image
2. Creates stable filename (e.g., `sudo cp mkosi.output/<name>_*.raw.xz mkosi.output/<name>.raw.xz`)
3. Uploads to GitHub release

## Common Tasks

### Update inventory for a machine
```bash
echo "dnsmasq_0.0.2" > docs/inventory/S7NRCX04S394286
git add docs/inventory/S7NRCX04S394286
git commit -m "Update S7NRCX04S394286 to dnsmasq 0.0.2"
git push
```

### Check which machines exist
```bash
ls docs/inventory/
```

### View current inventory for a machine
```bash
cat docs/inventory/<serial>
```

## Troubleshooting

- **Build failures**: Check that `OutputDirectory=mkosi.output` is in mkosi.conf
- **Release artifacts missing**: Ensure workflow uses `sudo cp` (mkosi runs as root)
- **Portable not attaching**: Check `journalctl -u entrypointd` on the machine
- **Inventory not updating**: GitHub Pages can take a few minutes to deploy
