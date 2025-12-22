# MicroCloud
## Overview
### Technologies Used
- Systemd Ecosystem
    - Mkosi, why?
        - Native systemd integration.
        - Lighter weight, simpler, than Packer.
        - Versatile, a single build artifact can run on multiple targets.
            - container(systemd-nspawn, oci)
            - VM, on a variety of hypervisors(Virtualbox, qemu/kvm
            - Even bare metal

### Machine Images
#### Booter
All machines boot the same image. At boot, we use the kernel parameter `systemd.pull`, to import(i.e. importctl) our `entrypointd` portable service. We pull rather than embed this, so we can decouple the building of machine images from the building of `entrypointd` images.

### Portables
#### Entrypointd
A service that gets a machine specific(`/sys/class/dmi/id/product_serial`) manifest of additional systemd portables, sysexts, and confexts, to import and attach. The resulting url is `https://oogy.github.io/microcloud/inventory/<product_serial>`. Continuously checks for and installs updated targets(query for current release -> file, path unit+handler if file changed).

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

## TODO
- [ ] push mkosi call down to image specific makefiles?
- [ ] Dedupe common arg patterns in Makefiles
- [ ] Parameratize entrypointd inventory url
- [ ] Split build and release of mkosi artifacts into separate workflows or at least separate jobs.
    - [ ] if jobs, share build output between jobs using upload-artifact action (?)
- [ ] Separate repo for all mkosi artifacts.
- [ ] support make individual images w/ type= and image= args.
- [ ] refine and generalize dev.sh flow

## Scratch
- Once entrypointd is working lets try just using dnsmasq and tftp, no matchbox.
- Spent too much trime trying to decouple entrypointd from image. Just bundle for now. Once entrypointd is working it won't change frequently so don't worry about needing a new image too much.
- need to chown the build output in postout since we're building as root now(issues w/ chown'ing the users home dir)
    - perhaps now that we've identified the login issue is with missing /bin/login we do not need the mcadmin user and can get away with autologin or rootpassword.
- why can't we login on the console? Selinx or apparmor blocking root login?
    - so thi$ turned out to be missing /bin/login on the image.
    - figured out I could
        1. Start the images w/ vmspawn or nspawn -b for faster test loop
        2. Force access to the running image with `machinectl shell <machine>`
        3. journalctl -f while trying to login which showed that
        ```
        Dec 22 09:01:36 mcbooter agetty[58]: pts/0: can't exec /bin/login: No such file or directory
        ```
        4. Fix with installing `login` package. Confusing that none of the metapackages install this.
- Add additional services to entrypointd
