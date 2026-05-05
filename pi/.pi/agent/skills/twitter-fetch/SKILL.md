---
name: twitter-fetch
description: Fetch public X/Twitter post content from nitter.tiekoetter.com using curl+pup, including child tweet links (thread/replies) visible on the page.
---

# Twitter Fetch (via nitter.tiekoetter.com)

Use this skill to read public tweet content from Nitter HTML when x.com is blocked or requires authentication.

## How to use

- Force load skill:

```bash
/skill:twitter-fetch <tweet-url>
```

- Helper script usage:

```bash
~/.pi/agent/skills/twitter-fetch/scripts/fetch-twitter-content.sh '<tweet-url>'
```

## Source URL

This skill resolves the status id and fetches:

```text
https://nitter.tiekoetter.com/i/status/<status_id>
```

(If a username is available from input, it may use `/<username>/status/<status_id>`.)

## Notes

- Use `curl + pup` parsing via the helper script.
- Child tweet links are included by default.
- When successful, report:
  - `NITTER_URL: <url>`
  - `Tweet text: <text>`
  - `Child tweet count: <count>`
  - `Child tweet URLs: <urls>`
