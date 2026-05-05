#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: fetch-twitter-content.sh <x/twitter/nitter status url or status id>" >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

if ! command -v pup >/dev/null 2>&1; then
  echo "ERROR=pup command not found in PATH" >&2
  exit 3
fi

input="$1"
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nitter_url="$($base_dir/find-working-mirror.sh "$input")"

# Match pi-scurl/web_fetch behavior to reduce anti-bot challenges.
ua='pi-scurl/0.1'
if ! html="$(curl -fsSL --max-time 25 -A "$ua" -H 'Accept: text/html,application/xhtml+xml,text/plain,application/json,*/*' "$nitter_url")"; then
  echo "ERROR=Failed to fetch $nitter_url" >&2
  exit 4
fi

if grep -qi 'anubis_challenge\|Making sure you&#39;re not a bot' <<<"$html"; then
  echo "ERROR=Nitter returned bot-challenge page; could not parse tweet content." >&2
  exit 5
fi

nitter_origin="$(printf '%s' "$nitter_url" | python3 -c 'import sys, urllib.parse as u; p=u.urlparse(sys.stdin.read().strip()); print(f"{p.scheme}://{p.netloc}")')"

normalize_text() {
  python3 -c 'import sys, html, re; s=html.unescape(sys.stdin.read()); s=s.replace("\xa0", " ").replace("Â·", "·"); s=re.sub(r"\s+", " ", s).strip();
if s:
    print(s)'
}

main_text="$(printf '%s' "$html" | pup '#m .tweet-content text{}' | normalize_text || true)"
full_name="$(printf '%s' "$html" | pup '#m .fullname text{}' | head -n 1 | normalize_text || true)"
screen_name="$(printf '%s' "$html" | pup '#m .username text{}' | head -n 1 | normalize_text || true)"
published_date="$(printf '%s' "$html" | pup '#m .tweet-published text{}' | head -n 1 | normalize_text || true)"
tweet_url="$(printf '%s' "$html" | pup 'head link[rel="alternate"] attr{href}' | head -n 1 | normalize_text || true)"

child_urls="$(printf '%s' "$html" | pup 'div.after-tweet a.tweet-link attr{href}' | python3 -c '
import sys
import urllib.parse as u
origin = sys.argv[1]
seen = set()
out = []
for line in sys.stdin:
    href = line.strip()
    if not href:
        continue
    href = href.split("#", 1)[0]
    abs_url = u.urljoin(origin + "/", href)
    if abs_url in seen:
        continue
    seen.add(abs_url)
    out.append(abs_url)
for item in out:
    print(item)
' "$nitter_origin" || true)"

child_count="$(printf '%s\n' "$child_urls" | python3 -c 'import sys; lines=[l.strip() for l in sys.stdin if l.strip()]; print(len(lines))')"

printf 'NITTER_URL=%s\n' "$nitter_url"
if [[ -n "$tweet_url" ]]; then
  printf 'TWEET_URL=%s\n' "$tweet_url"
fi

if [[ -n "$full_name" && -n "$screen_name" ]]; then
  printf 'TITLE=%s (%s)\n' "$full_name" "$screen_name"
elif [[ -n "$full_name" ]]; then
  printf 'TITLE=%s\n' "$full_name"
fi

if [[ -n "$published_date" ]]; then
  printf 'DATE=%s\n' "$published_date"
fi

if [[ -n "$main_text" ]]; then
  printf 'TEXT=%s\n' "$main_text"
fi

printf 'CHILDREN_INCLUDED=1\n'
printf 'CHILD_COUNT=%s\n' "$child_count"
if [[ -n "$child_urls" ]]; then
  while IFS= read -r child_url; do
    [[ -z "$child_url" ]] && continue
    printf 'CHILD_URL=%s\n' "$child_url"
  done <<< "$child_urls"
fi

if [[ -z "$main_text" ]]; then
  echo "NOTE=Nitter responded but tweet text was not found." >&2
fi
