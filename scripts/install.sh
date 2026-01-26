#!/usr/bin/env bash
set -euo pipefail

ensure_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "error: run as root" >&2
    exit 1
  fi
}

install_microcloud_host_script() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  install -m 0755 "${script_dir}/microcloud-host" /usr/local/bin/microcloud-host
}

install_microcloud_host_service() {
  cat > /etc/systemd/system/microcloud-host.service <<'EOF'
[Unit]
Description=Microcloud host configuration
ConditionPathExists=!/var/lib/microcloud/host.done
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/microcloud-host
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
}

install_microcloud_host_target() {
  cat > /etc/systemd/system/microcloud-host.target <<'EOF'
[Unit]
Description=Microcloud host configuration complete
ConditionPathExists=/var/lib/microcloud/host.done

[Install]
WantedBy=multi-user.target
EOF
}

reload_systemd() {
  systemctl daemon-reload
}

enable_service() {
  systemctl enable microcloud-host.service
}

main() {
  ensure_root
  install_microcloud_host_script
  install_microcloud_host_service
  install_microcloud_host_target
  reload_systemd
  enable_service
}

main "$@"
