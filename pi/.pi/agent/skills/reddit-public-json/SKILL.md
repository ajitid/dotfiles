---
name: reddit-public-json
description: Fetch and parse Reddit thread JSON using OAuth app-only credentials. Use when users ask for quick Reddit post/comment reactions from public threads.
---

# Reddit Public JSON (OAuth)

Use this skill to fetch Reddit thread JSON from public Reddit threads via OAuth and extract top comments safely in small payloads.

## When to use

- User asks for reactions/opinions in a Reddit thread
- User wants public Reddit thread JSON
- Need `curl | jq` commands that avoid unauthenticated Reddit `.json` 403 issues

## Notes

- The script uses OAuth `client_credentials` and `https://oauth.reddit.com` for public threads.
- `reddit-token.sh` caches the bearer token under `${XDG_CACHE_HOME:-$HOME/.cache}/pi/reddit-public-json/token.json`.
- Keep payloads small with `limit` and especially `depth`.
- For public-only mode, prefer sampling top-level comments (`depth=1`).
- `reddit-top-comments.sh` now filters low-signal comments by default:
  - excludes stickied comments
  - excludes `[removed]` bodies

## Generic thread URL

```text
https://oauth.reddit.com/r/{sub}/comments/{post_id}?raw_json=1&sort=top&limit=20&depth=1
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
TOKEN=$(curl -fsSL \
  -A "$REDDIT_USER_AGENT" \
  -u "$REDDIT_CLIENT_ID:$REDDIT_CLIENT_SECRET" \
  -d grant_type=client_credentials \
  https://www.reddit.com/api/v1/access_token \
| jq -r '.access_token')

URL='https://oauth.reddit.com/r/{sub}/comments/{post_id}?raw_json=1&sort=top&limit=20&depth=1'

curl -fsSL \
  -A "$REDDIT_USER_AGENT" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Accept: application/json' \
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

## Notes

- If OAuth environment variables are missing, scripts fail with setup instructions. Stop and ask the user to set them up first so you can proceed.
- If response is too large, lower `limit` and set `depth=1`.
- Scripts now fail fast with clear messages if required tools are missing (`curl` for fetch/token, `jq` for token parsing/comment parse). If tools are unavailable, stop and ask the user to install them so you can proceed.
