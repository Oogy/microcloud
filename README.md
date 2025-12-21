# MicroCloud
## Overview
### Technologies Used
- Systemd Ecosystem
    - Mkosi, why?
        - Native systemd integration.
        - Lighter weight, simpler, than Packer.
        - Versatile, a single build artifact can run on multiple targets.
            - container(systemd-nspawn)
            - VM, on a variety of hypervisors(Virtualbox, qemu/kvm
            - Even bare metal

### Machine Images
#### Booter
All machines boot the same image. At boot, we use the kernel parameter `systemd.pull`, to import(i.e. importctl) our `entrypointd` portable service. We pull rather than embed this, so we can decouple the building of machine images from the building of `entrypointd` images.
### Portables
#### Entrypointd
A service that gets a machine specific(`/sys/class/dmi/id/product_serial`) manifest of additional systemd portables, sysexts, and confexts, to import and attach. The resulting url is `https://oogy.github.io/microcloud/inventory/<product_serial>`. Continuously checks for and installs updated targets.
#### Matchbox
#### DNSMasq

### Side Quest: Git + CI/CD Server
- Git hooks = ci/cd jobs/pipelines
- executes systemd-run transient services
    - job config
        - name
        - script
- job browser
    - state[running, pass, fail, etc.]
    - name
    - branch/ref
    - start, stop, duration
