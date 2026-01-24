#!/usr/bin/env bash
set -euo pipefail

ghcr_pull_secret() {
    local token username auth config
    token=$(gh auth token)
    username=$(gh api user --jq '.login')
    auth=$(echo -n "$username:$token" | base64 -w0)
    config=$(echo -n "{\"auths\":{\"ghcr.io\":{\"auth\":\"$auth\"}}}" | base64 -w0)
    echo "$config"
}
