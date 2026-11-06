#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed or not in PATH." >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <item_id> [pretty]" >&2
  exit 1
fi

item_id="$1"
mode="${2:-raw}"
url="https://api.hackerwebapp.com/item/${item_id}"

if [[ "$mode" == "pretty" ]]; then
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required for pretty mode." >&2
    exit 1
  fi
  curl -fsSL -H 'User-Agent: pi-scurl/0.1' "$url" | jq .
else
  curl -fsSL -H 'User-Agent: pi-scurl/0.1' "$url"
fi
