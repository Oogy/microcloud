# Microcloud

## Install

Two supported install paths:

1) Image prep (default)
- Runs `scripts/install.sh`
- Example:
  - `curl -fsSL https://raw.githubusercontent.com/Oogy/microcloud/main/scripts/install.sh | bash`
- Installs the k0s binary
- Installs `/usr/local/bin/microcloud-bootstrap`
- Installs and enables the systemd oneshot: `microcloud-bootstrap.service`

2) Bootstrap now (ad hoc)
- Runs `scripts/install.sh --now`
- Example:
  - `curl -fsSL https://raw.githubusercontent.com/Oogy/microcloud/main/scripts/install.sh | bash -s -- --now`
- Performs the image prep steps above
- Immediately bootstraps k0s and applies the Argo CD manifest

## Bootstrap

The bootstrap step runs:
- `k0s_bootstrap` (single-node controller + start)
- `argocd_install_manifest` (applies the Argo CD manifest via `k0s kubectl`)
