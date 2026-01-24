#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/k0s"

k0s_install() {
    curl -sSLf https://get.k0s.sh | sudo sh
    sudo mkdir -p /etc/k0s
    sudo mkdir -p /var/lib/k0s/manifests
    sudo cp "$CONFIG_DIR/containerd.toml" /etc/k0s/containerd.toml
    sudo cp "$CONFIG_DIR/manifests/"* /var/lib/k0s/manifests/
    sudo k0s install controller --single -c "$CONFIG_DIR/k0s.yaml"
    sudo k0s start
    sudo k0s status
}

k0s_uninstall() {
    sudo k0s stop
    sudo k0s reset
    sudo rm -f /usr/local/bin/k0s
}

k0s_gpu_test() {
    sudo k0s kubectl run gpu-test --rm -it --restart=Never \
        --image=nvidia/cuda:12.6.3-base-ubuntu24.04 -- nvidia-smi
}
