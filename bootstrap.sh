#!/bin/bash
# Bootstrap microcloud GitHub infrastructure using gh CLI
# Run this from a phone or any device with gh authenticated

set -e

ORG="Oogy"

# Repository definitions: name|description|pages_path (empty = no pages)
REPOS=(
  "microcloud|Orchestrator for baremetal local cloud|/docs"
  "booter|Bootable machine image for microcloud|"
  "entrypointd-portable|Portable service manager for microcloud|"
  "dnsmasq-portable|PXE/TFTP server portable for microcloud|"
)

create_repo() {
  local name="$1"
  local description="$2"
  local pages_path="$3"

  echo "=== $name ==="

  # Check if repo exists
  if gh repo view "$ORG/$name" &>/dev/null; then
    echo "  Repo exists"
  else
    echo "  Creating repo..."
    gh repo create "$ORG/$name" --public --description "$description"
  fi

  # Enable Pages if path specified
  if [ -n "$pages_path" ]; then
    echo "  Enabling GitHub Pages (branch: main, path: $pages_path)..."
    gh api -X PUT "/repos/$ORG/$name/pages" \
      -f source[branch]=main \
      -f source[path]="$pages_path" 2>/dev/null || \
    gh api -X POST "/repos/$ORG/$name/pages" \
      -f source[branch]=main \
      -f source[path]="$pages_path" 2>/dev/null || \
    echo "  Pages already configured or needs manual setup"
  fi

  echo ""
}

echo "Bootstrapping microcloud infrastructure..."
echo ""

for repo_def in "${REPOS[@]}"; do
  IFS='|' read -r name description pages_path <<< "$repo_def"
  create_repo "$name" "$description" "$pages_path"
done

echo "Done!"
echo ""
echo "Repos: https://github.com/$ORG?tab=repositories&q=microcloud+OR+booter+OR+portable"
