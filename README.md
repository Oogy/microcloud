# MicroCloud
## Overview
### Machine Images
#### Booter
All machines boot the same image. At boot, we use the kernel parameter `systemd.pull`, to import(i.e. importctl) our `entrypointd` portable service. We pull rather than embed this, so we can decouple the building of machine images from the building of `entrypointd` images.
### Portables
#### Entrypointd
A service that GET's a machine specific(`/sys/class/dmi/id/product_serial`) manifest of additional portable services to import and attach.
#### Matchbox
#### DNSMasq
