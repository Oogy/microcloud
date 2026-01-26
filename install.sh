#!/usr/bin/env bash
set -euo pipefail

run_install() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "${script_dir}/scripts/install.sh"
}

main() {
  run_install "$@"
}

main "$@"
