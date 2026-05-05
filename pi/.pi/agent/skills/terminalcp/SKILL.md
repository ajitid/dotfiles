---
name: terminalcp
description: Run and control interactive terminal sessions with a real PTY from Pi. Use for REPLs, debuggers, TUIs, and workflows that need keyboard input (Enter, arrows, Ctrl+C) and persistent sessions.
compatibility: Requires `terminalcp` command available in PATH.
---

## Quick start

1. Start a named session:
```bash
terminalcp start py "python3 -i"
```

2. Send input in batches when possible:
```bash
terminalcp stdin py "2+2" ::Enter
```

3. Read the smallest useful output:
- Rendered terminal state (best for REPL/TUI/debugger checks):
```bash
terminalcp stdout py 40
```
- Incremental log updates (best for long-running output):
```bash
terminalcp stream py --since-last
```

4. Stop when done:
```bash
terminalcp stop py
```

## Common keys
- Enter: `::Enter`
- Ctrl+C: `::C-c`
- Arrows: `::Up` `::Down` `::Left` `::Right`
- Page: `::PageUp` `::PageDown`

## Good practices

- Always start sessions with a stable name
- Use small `stdout` line counts for status checks
- Prefer `stream --since-last` for noisy processes
- Stop sessions explicitly to avoid leftovers

## More Info

Run `terminalcp` (without args) to see available commands.
