## Suggestions

Use Codex in Pi and use Amp Free. GLM is ok-ish but its servers largely remain down.

## CLI tools

CLI tools I have installed for Pi:
- ripgrep, jq
- https://github.com/benibela/xidel
- `bun i -g @mariozechner/terminalcp` along with see heading `## fixing terminalcp`
- deps install wherever you see `fd package.json`

## Sources

## System prompt

The section "On responding" is taken from https://simonwillison.net/2026/Apr/18/opus-system-prompt/

### Extensions:

- answer, prompt-editor, whimsical, multi-edit: all from mitsuhiko/agent-stuff, and some of whimsical is from me
  - I don't use the 'answer' extension at all tho. just have put there as it is a good pt of reference
- review from earendil-works/pi-review (earlier was from mitsuhiko/agent-stuff)
- comment [code](https://gist.github.com/badlogic/563f245975444dbeedd1a93de95a5e92) [tweet](https://x.com/badlogicgames/status/2051278108532109573)

### Skills:

- youtube-transcript - from https://github.com/badlogic/pi-skills/
  - though beside youtube-transcript, for blog post i'd recommend turning them into a podcast using NotebookLM and then skimming the blog post for once to take on the interesting bits
  - these skills are disabled by default to not consume tokens unnecessarily
- terminalcp - tool at https://github.com/badlogic/terminalcp/ some skill info possibly inferred from https://github.com/badlogic/terminalcp/blob/main/test/eval/tools/terminalcp-cli.md
- voy - based on browser-tools from https://github.com/badlogic/pi-skills/
- rest are by me

## Other info

For retrieving specific sites for now I'm opting for specific alt sites to get data but https://farside.link/ also looks promising

For Cursor models, I use [pi-cursor-sdk](https://github.com/fitchmultz/pi-cursor-sdk).

## Web fetch

I am using pi-scurl extension to fetch. When it fails to load an SPA page, the agent uses pi-linkup's web fetch which does resolve the contents.

## Search

Used to use 4get.ca now using linkup. No particular reason for the switch tho.

Using `security` cli to store linkup's the token.

```
If by security (macOS Keychain) and op (1Password CLI) you mean “what else can I use from CLI to store secrets?”, common options are:

- pass (Password Store, GPG-backed)
Simple, file-based, very Unix-y.
- gopass
A more feature-rich pass-style manager (teams, mounts, better UX).
- keyring / secret-tool / kwallet (desktop keychains)
    - Linux GNOME: secret-tool
    - KDE: kwallet
    - Cross-platform via language libs: keyring
- vault (HashiCorp Vault CLI)
Best for infra/server-side, dynamic credentials, policies, audit logs.
- aws secretsmanager / aws ssm
If you’re on AWS already, very practical for app/runtime secrets.
- gcloud secrets (Google Secret Manager CLI)
Similar for GCP stacks.
- az keyvault (Azure Key Vault CLI)
Similar for Azure stacks.
- sops + age/GPG
Encrypt secrets in files (great for GitOps / repo-stored encrypted config).
- doppler CLI
Developer-friendly hosted secret manager with environment injection.
```

## Fixing terminal

Root cause is **not your `pnpm ui` command** — it’s a `node-pty` runtime packaging/permission issue in the installed `terminalcp`.

### What I verified

In `~/n/lib/node_modules/@mariozechner/terminalcp`:

- `terminalcp` depends on `node-pty` via `^1.0.0`, and your installed copy resolved to **`node-pty@1.1.0`**.
- Its helper binary was at:
  - `~/n/lib/node_modules/@mariozechner/terminalcp/node_modules/node-pty/prebuilds/darwin-arm64/spawn-helper`
- It initially had **no execute bit** (`-rw-r--r--`), which causes `pty.spawn(...)` to throw:
  - `Error: posix_spawnp failed.`

I confirmed causality by toggling permission:

- `chmod -x spawn-helper` → spawn fails with `posix_spawnp failed`
- `chmod +x spawn-helper` → spawn succeeds

So the concrete root cause is:

> `node-pty`’s `spawn-helper` in your installed terminalcp package was non-executable on macOS arm64, causing all `terminalcp start` calls to fail immediately with `posix_spawnp failed`.

(Your local repo copy works because it uses a different node-pty build layout and executable helper.)
