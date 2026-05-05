#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not installed or not in PATH." >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <reddit_thread_json_file> [top_n] [--recursive|-r]" >&2
  exit 1
fi

file="$1"
shift

top_n=20
recursive=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --recursive|-r)
      recursive=1
      shift
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        top_n="$1"
        shift
      else
        echo "Error: Unknown argument '$1'" >&2
        echo "Usage: $0 <reddit_thread_json_file> [top_n] [--recursive|-r]" >&2
        exit 1
      fi
      ;;
  esac
done

jq -r \
  --argjson recursive "$recursive" '
  def flatten_replies:
    . as $c
    | $c,
      ($c.data.replies?
       | if type == "object" then .data.children[] | flatten_replies else empty end);

  def high_signal:
    .kind == "t1"
    and ((.data.stickied // false) | not)
    and ((.data.body // "") != "[removed]");

  if $recursive == 1 then
    .[1].data.children[] | flatten_replies | select(high_signal)
  else
    .[1].data.children[] | select(high_signal)
  end
  | [.data.ups, .data.author, ((.data.body // "") | gsub("\\n"; " "))]
  | @tsv
' "$file" \
| sort -nr \
| head -n "$top_n"
