#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed or not in PATH." >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <sub> <post_id> [sort] [limit] [depth]" >&2
  exit 1
fi

sub="$1"
post_id="$2"
sort="${3:-top}"
limit="${4:-20}"
depth="${5:-1}"

token="$($script_dir/reddit-token.sh)"
url="https://oauth.reddit.com/r/${sub}/comments/${post_id}?raw_json=1&sort=${sort}&limit=${limit}&depth=${depth}"

curl -fsSL \
  -A "$REDDIT_USER_AGENT" \
  -H "Authorization: Bearer $token" \
  -H 'Accept: application/json' \
  "$url"
