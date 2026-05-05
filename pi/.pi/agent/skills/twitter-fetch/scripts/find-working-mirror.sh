#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <x/twitter/nitter status url or status id>" >&2
  exit 1
fi

input="$1"
base="https://nitter.tiekoetter.com"
ua='pi-scurl/0.1'

extract_status_id() {
  local s="$1"
  if [[ "$s" =~ status/([0-9]{6,}) ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi
  if [[ "$s" =~ ^[0-9]{6,}$ ]]; then
    echo "$s"
    return 0
  fi
  return 1
}

extract_username() {
  local s="$1"
  if [[ "$s" =~ https?://[^/]+/([A-Za-z0-9_]+)/status/[0-9]{6,} ]]; then
    local user="${BASH_REMATCH[1]}"
    if [[ "$user" != "i" && "$user" != "status" ]]; then
      echo "$user"
      return 0
    fi
  fi
  return 1
}

status_id="$(extract_status_id "$input" || true)"
if [[ -z "${status_id:-}" ]]; then
  echo "Could not extract status id from input: $input" >&2
  exit 2
fi

username="$(extract_username "$input" || true)"
if [[ -n "$username" ]]; then
  primary_url="$base/$username/status/$status_id"
else
  primary_url="$base/i/status/$status_id"
fi

fallback_url="$base/i/status/$status_id"

if curl -fsSIL --max-time 20 -A "$ua" "$primary_url" >/dev/null; then
  echo "$primary_url"
  exit 0
fi

if curl -fsSIL --max-time 20 -A "$ua" "$fallback_url" >/dev/null; then
  echo "$fallback_url"
  exit 0
fi

echo "Failed to reach nitter.tiekoetter.com for status id: $status_id" >&2
exit 3
