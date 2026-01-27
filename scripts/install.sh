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

install_hosts_data() {
  local repo_root
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  mkdir -p /usr/local/share/microcloud/hosts
  cp -f "${repo_root}/hosts/"*.yaml /usr/local/share/microcloud/hosts/
}

install_microcloud_k8s_script() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  install -m 0755 "${script_dir}/microcloud-k8s" /usr/local/bin/microcloud-k8s
}

install_microcloud_k8s_service() {
  cat > /etc/systemd/system/microcloud-k8s.service <<'EOF'
[Unit]
Description=Microcloud k0s bootstrap
ConditionPathExists=!/var/lib/microcloud/k8s.done
After=network-online.target microcloud-host.target
Wants=network-online.target microcloud-host.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/microcloud-k8s
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
}

install_microcloud_k8s_target() {
  cat > /etc/systemd/system/microcloud-k8s.target <<'EOF'
[Unit]
Description=Microcloud k0s bootstrap complete
ConditionPathExists=/var/lib/microcloud/k8s.done

[Install]
WantedBy=multi-user.target
EOF
}

install_microcloud_argocd_script() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  install -m 0755 "${script_dir}/microcloud-argocd" /usr/local/bin/microcloud-argocd
}

install_microcloud_argocd_service() {
  cat > /etc/systemd/system/microcloud-argocd.service <<'EOF'
[Unit]
Description=Microcloud Argo CD install
ConditionPathExists=!/var/lib/microcloud/argocd.done
After=network-online.target microcloud-k8s.target
Wants=network-online.target microcloud-k8s.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/microcloud-argocd
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
}

install_microcloud_argocd_target() {
  cat > /etc/systemd/system/microcloud-argocd.target <<'EOF'
[Unit]
Description=Microcloud Argo CD install complete
ConditionPathExists=/var/lib/microcloud/argocd.done

[Install]
WantedBy=multi-user.target
EOF
}

install_microcloud_appset_script() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  install -m 0755 "${script_dir}/microcloud-appset" /usr/local/bin/microcloud-appset
}

install_microcloud_appset_service() {
  cat > /etc/systemd/system/microcloud-appset.service <<'EOF'
[Unit]
Description=Microcloud ApplicationSet install
ConditionPathExists=!/var/lib/microcloud/appset.done
After=network-online.target microcloud-argocd.target
Wants=network-online.target microcloud-argocd.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/microcloud-appset
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
}

install_microcloud_appset_target() {
  cat > /etc/systemd/system/microcloud-appset.target <<'EOF'
[Unit]
Description=Microcloud ApplicationSet install complete
ConditionPathExists=/var/lib/microcloud/appset.done

[Install]
WantedBy=multi-user.target
EOF
}

reload_systemd() {
  systemctl daemon-reload
}

enable_service() {
  systemctl enable microcloud-host.service
  systemctl enable microcloud-k8s.service
  systemctl enable microcloud-argocd.service
  systemctl enable microcloud-appset.service
}

start_services_now() {
  systemctl start microcloud-host.service
  systemctl start microcloud-k8s.service
  systemctl start microcloud-argocd.service
  systemctl start microcloud-appset.service
}

parse_args() {
  START_NOW=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --now)
        START_NOW=1
        shift
        ;;
      *)
        echo "usage: $0 [--now]" >&2
        exit 2
        ;;
    esac
  done
}

main() {
  ensure_root
  parse_args "$@"
  install_microcloud_host_script
  install_microcloud_host_service
  install_microcloud_host_target
  install_hosts_data
  install_microcloud_k8s_script
  install_microcloud_k8s_service
  install_microcloud_k8s_target
  install_microcloud_argocd_script
  install_microcloud_argocd_service
  install_microcloud_argocd_target
  install_microcloud_appset_script
  install_microcloud_appset_service
  install_microcloud_appset_target
  reload_systemd
  enable_service
  if [[ "${START_NOW}" -eq 1 ]]; then
    start_services_now
  fi
}

main "$@"
