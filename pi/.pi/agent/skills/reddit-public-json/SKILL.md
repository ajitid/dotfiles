---
name: reddit-public-json
description: Fetch and parse public Reddit thread JSON without OAuth/app keys using curl+jq with a stable User-Agent. Use when users ask for quick Reddit post/comment reactions from publicly available .json endpoints.
---

# Reddit Public JSON (No OAuth)

Use this skill to fetch Reddit thread JSON from public `.json` endpoints and extract top comments safely in small payloads.

## When to use

- User asks for reactions/opinions in a Reddit thread
- User wants public `.json` only (no API key/OAuth)
- Need `curl | jq` commands that avoid common 403 issues

## Notes

- Public `.json` can be rate-limited/blocked depending on User-Agent and environment.
- Use a non-default User-Agent (e.g., `pi-scurl/0.1`).
- Keep payloads small with `limit` and especially `depth`.
- For public-only mode, prefer sampling top-level comments (`depth=1`).
- `reddit-top-comments.sh` now filters low-signal comments by default:
  - excludes stickied comments
  - excludes `[removed]` bodies

## Generic thread URL

```text
https://www.reddit.com/r/{sub}/comments/{post_id}/.json?raw_json=1&sort=top&limit=20&depth=1
```

## Quick commands

### 1) Fetch raw JSON to a file

```bash
~/.pi/agent/skills/reddit-public-json/scripts/reddit-json.sh <sub> <post_id> [sort] [limit] [depth] > /tmp/reddit-thread.json
```

### 2) Print filtered comments as TSV (ups, author, body)

Top-level only (default):

```bash
~/.pi/agent/skills/reddit-public-json/scripts/reddit-top-comments.sh /tmp/reddit-thread.json [top_n]
```

Include nested replies (fetch with `depth>1` in step 1):

```bash
~/.pi/agent/skills/reddit-public-json/scripts/reddit-top-comments.sh /tmp/reddit-thread.json [top_n] --recursive
```


## One-liner (no helper scripts)

```bash
URL='https://www.reddit.com/r/{sub}/comments/{post_id}/.json?raw_json=1&sort=top&limit=20&depth=1'

curl -fsSL \
  -H 'User-Agent: pi-scurl/0.1' \
  -H 'Accept: text/html,application/xhtml+xml,text/plain,application/json,*/*' \
  "$URL" \
| jq -r '
  .[1].data.children[]
  | select(.kind=="t1")
  | select((.data.stickied // false) | not)
  | select((.data.body // "") != "[removed]")
  | [.data.ups, .data.author, ((.data.body // "")|gsub("\\n";" "))]
  | @tsv
' | sort -nr
```

## Fallbacks

- If request returns `403`, retry with same headers and a small `limit`.
- If request returns `429`, wait and retry.
- If response is too large, lower `limit` and set `depth=1`.
- Scripts now fail fast with clear messages if required tools are missing (`curl` for fetch, `jq` for parse).
