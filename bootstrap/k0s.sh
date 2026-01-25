#!/bin/bash
set -euo pipefail

# Install k0s single-node cluster

curl -sSLf https://get.k0s.sh | sudo sh

sudo k0s install controller --single
sudo k0s start

# Wait for k0s to be ready
echo "Waiting for k0s to be ready..."
until sudo k0s kubectl get nodes &>/dev/null; do
    sleep 5
done

# Setup kubeconfig for root
mkdir -p /root/.kube
sudo k0s kubeconfig admin > /root/.kube/config
chmod 600 /root/.kube/config

echo "k0s installed and running"
