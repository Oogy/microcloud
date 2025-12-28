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
A minimally bootable image shared by all machines based on Ubuntu Questing.

### Portables
#### Entrypointd
This is currently embedded directly into the `booter` image. queries the host specific inventory endpoint(`oogy.github.io/microcloud/inventory/<serial>.html`) for a list of tagged systemd portable services to import and attach, achieving machine specific goals from the same image. While embedded in the image it is developed independently as a portable service, so that using a combination of `inotifywait`, and `machinectl copy-to`, we can develop the `entrypointd` script and observe behavior in real time without needing to repeatedly build the image.

#### DNSMasq
Runs in proxy-dhcp mode and serves the `booter` machine image via TFTP to local cluster members.

## TODO
- [ ] Matrix strategy for separate image builds, pass artifacts to release job
- [ ] push mkosi call down to image specific makefiles?
- [ ] Dedupe common arg patterns in Makefiles
- [ ] Parameratize entrypointd inventory url
- [ ] Split build and release of mkosi artifacts into separate workflows or at least separate jobs.
    - [ ] if jobs, share build output between jobs using upload-artifact action (?)
- [ ] Separate repo for all mkosi artifacts.
- [ ] support make individual images w/ type= and image= args.
- [ ] refine and generalize dev.sh flow

## Scratch
- entrypointd FIX: only reattach on downloads
- What happens if we set portables Format=portables instead of disk?
- Why this error on portablectl attaching dnsmasq:
```
Dec 23 16:04:49 entrypointd portablectl[79]: AttachImage failed: No such file or directory
```
- Booter too big to fit in release artifacts. Need to get it under 2Gi.
- seems to be a problem w/ apt cache when building on Github Runner?
    - doesn't error on individual builds. Network saturation?
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
