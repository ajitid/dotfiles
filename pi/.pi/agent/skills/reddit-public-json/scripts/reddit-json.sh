#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed or not in PATH." >&2
  exit 1
fi

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <sub> <post_id> [sort] [limit] [depth]" >&2
  exit 1
fi

sub="$1"
post_id="$2"
sort="${3:-top}"
limit="${4:-20}"
depth="${5:-1}"

url="https://www.reddit.com/r/${sub}/comments/${post_id}/.json?raw_json=1&sort=${sort}&limit=${limit}&depth=${depth}"

curl -fsSL \
  -H 'User-Agent: pi-scurl/0.1' \
  -H 'Accept: text/html,application/xhtml+xml,text/plain,application/json,*/*' \
  "$url"
