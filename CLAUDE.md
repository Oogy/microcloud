# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

microcloud is the orchestrator for a baremetal local cloud. It manages inventory and infrastructure while the actual images live in separate repos.

## Repository Structure

```
microcloud/
├── docs/                    # GitHub Pages site
│   ├── index.html          # Landing page
│   └── inventory/          # Machine-specific portable lists
│       └── <serial>        # File per machine serial number
└── terraform/              # Infrastructure as code
    └── main.tf
```

## Related Repositories

- [booter](https://github.com/Oogy/booter) - Main bootable machine image (mkosi)
- [entrypointd-portable](https://github.com/Oogy/entrypointd-portable) - Portable service manager
- [dnsmasq-portable](https://github.com/Oogy/dnsmasq-portable) - PXE/TFTP server

## Inventory Management

Machine inventory files in `docs/inventory/<serial>` determine which portables each machine runs. Format is newline-separated `<name>_<version>`:

```
dnsmasq_0.0.11
```

To add a new machine:
1. Get serial from `/sys/class/dmi/id/product_serial`
2. Create `docs/inventory/<serial>` with desired portables
3. Commit and push - GitHub Pages auto-deploys

## How Boot Works

1. Machine PXE boots, receives booter image from dnsmasq-portable
2. booter starts, attaches entrypointd-portable via portablectl
3. entrypointd reads machine serial, fetches `oogy.github.io/microcloud/inventory/<serial>`
4. entrypointd downloads and attaches listed portables via `portablectl`
