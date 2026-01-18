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
                    │ - bootstrap.sh  │
                    │ - docs          │
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

## Inventory

Machine-specific configuration lives in `docs/inventory/<serial>`. Each file contains newline-separated portable service names to attach:

```
dnsmasq_0.0.1
```

Served via GitHub Pages at `oogy.github.io/microcloud/inventory/<serial>`.

## Technologies

- **mkosi** - systemd's image builder for reproducible OS images
- **systemd portables** - lightweight service isolation without containers
- **PXE/TFTP** - network boot for bare metal provisioning
