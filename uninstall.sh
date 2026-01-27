#!/usr/bin/env bash
set -euo pipefail

run_uninstall() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "${script_dir}/scripts/uninstall.sh"
}

main() {
  run_uninstall "$@"
}

main "$@"
