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

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <item_id> [top_n] [--top-level]" >&2
  exit 1
fi

item_id="$1"
top_n="${2:-20}"
mode="${3:-recursive}"
url="https://api.hackerwebapp.com/item/${item_id}"

json="$(curl -fsSL -H 'User-Agent: pi-scurl/0.1' "$url")"

echo -e "level\tid\tuser\ttime_ago\tcontent"

if [[ "$mode" == "--top-level" ]]; then
  jq -r --argjson n "$top_n" '
    .comments[0:$n][]
    | [
        (.level // 0),
        .id,
        (.user // ""),
        (.time_ago // ""),
        ((.content // "")
          | gsub("<[^>]+>"; " ")
          | gsub("\\s+"; " ")
          | ltrimstr(" ")
          | rtrimstr(" "))
      ]
    | @tsv
  ' <<<"$json"
else
  jq -r --argjson n "$top_n" '
    def flat:
      .[] as $c
      | $c, ($c.comments | flat);

    (.comments | flat)
    | [
        (.level // 0),
        .id,
        (.user // ""),
        (.time_ago // ""),
        ((.content // "")
          | gsub("<[^>]+>"; " ")
          | gsub("\\s+"; " ")
          | ltrimstr(" ")
          | rtrimstr(" "))
      ]
    | @tsv
  ' <<<"$json" | head -n "$top_n"
fi
