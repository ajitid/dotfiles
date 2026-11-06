#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required but not installed or not in PATH." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed or not in PATH." >&2
  exit 1
fi

missing=()
[[ -n "${REDDIT_CLIENT_ID:-}" ]] || missing+=(REDDIT_CLIENT_ID)
[[ -n "${REDDIT_CLIENT_SECRET:-}" ]] || missing+=(REDDIT_CLIENT_SECRET)
[[ -n "${REDDIT_USER_AGENT:-}" ]] || missing+=(REDDIT_USER_AGENT)

if [[ ${#missing[@]} -gt 0 ]]; then
  cat >&2 <<'EOF'
Error: Reddit OAuth credentials are not configured.

Create a Reddit app here:
  https://www.reddit.com/prefs/apps

Use app type "script" or "web app". If Reddit asks for a redirect URI and you do not need an interactive flow, use:
  http://localhost:8080

Set these environment variables:
  export REDDIT_CLIENT_ID='your app client id'
  export REDDIT_CLIENT_SECRET='your app client secret'
  export REDDIT_USER_AGENT='linux:pi-reddit-skill:v0.1 by u_YOURUSERNAME'

Use a specific, non-default User-Agent that includes platform/app/version and your Reddit username.
EOF
  printf 'Missing:' >&2
  printf ' %s' "${missing[@]}" >&2
  printf '\n' >&2
  exit 1
fi

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/pi/reddit-public-json"
cache_file="$cache_dir/token.json"
now="$(date +%s)"

if [[ -f "$cache_file" ]]; then
  expires_at="$(jq -r '.expires_at // 0' "$cache_file" 2>/dev/null || printf '0')"
  token="$(jq -r '.access_token // empty' "$cache_file" 2>/dev/null || true)"
  if [[ -n "$token" && "$expires_at" =~ ^[0-9]+$ && "$expires_at" -gt $((now + 60)) ]]; then
    printf '%s\n' "$token"
    exit 0
  fi
fi

mkdir -p "$cache_dir"
chmod 700 "$cache_dir"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL \
  -A "$REDDIT_USER_AGENT" \
  -u "$REDDIT_CLIENT_ID:$REDDIT_CLIENT_SECRET" \
  -d grant_type=client_credentials \
  https://www.reddit.com/api/v1/access_token \
| jq --argjson now "$now" '
    if (.access_token? | type) != "string" then
      error("Reddit token response did not include access_token")
    else
      . + {expires_at: ($now + (.expires_in // 3600) - 60)}
    end
  ' > "$tmp"

chmod 600 "$tmp"
mv "$tmp" "$cache_file"
trap - EXIT

jq -r '.access_token' "$cache_file"
