---
name: hackernews-hackerweb
description: Fetch Hacker News stories/comments from api.hackerwebapp.com using lightweight JSON. Supports story and comment IDs.
---

# Hacker News via HackerWeb API

Use this skill when you want compact HN content with fewer tokens than Algolia or Firebase item trees.

## Endpoints

- Item by ID (story or comment):

```text
https://api.hackerwebapp.com/item/<id>
```


## Notes

- A **comment ID** is fetched exactly like a story ID: `/item/<comment_id>`.
- Comment responses return that comment as root + nested replies in `comments`.
- This API includes useful LLM-friendly fields like `time_ago`, `domain`, and `level`.

## Quick commands

### 1) Fetch an item (raw or pretty)

```bash
~/.pi/agent/skills/hackernews-hackerweb/scripts/hackerweb-item.sh 47204027 pretty
~/.pi/agent/skills/hackernews-hackerweb/scripts/hackerweb-item.sh 47240200 pretty
```

### 2) Print flattened comments (TSV)

Top comments + nested replies:

```bash
~/.pi/agent/skills/hackernews-hackerweb/scripts/hackerweb-comments.sh 47204027 20
```

Top-level only:

```bash
~/.pi/agent/skills/hackernews-hackerweb/scripts/hackerweb-comments.sh 47204027 20 --top-level
```

Output columns:

```text
level\tid\tuser\ttime_ago\tcontent
```
