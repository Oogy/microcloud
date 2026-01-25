#!/bin/bash
set -euo pipefail

# Install entrypointd

readonly RAW_URL="https://raw.githubusercontent.com/Oogy/microcloud/main"

echo "Installing entrypointd..."

curl -fsSL "${RAW_URL}/entrypointd/entrypointd.sh" -o /usr/local/bin/entrypointd.sh
chmod +x /usr/local/bin/entrypointd.sh

curl -fsSL "${RAW_URL}/entrypointd/entrypointd.service" -o /etc/systemd/system/entrypointd.service

systemctl daemon-reload
systemctl enable entrypointd.service

echo "entrypointd installed. Will run on next boot."
echo "Run 'systemctl start entrypointd' to bootstrap now."
