/**
 * Session Info Extension
 *
 * - Ctrl+; copies the current session ID to clipboard
 * - Interactive mode: on exit, prints a single resume line for the last session
 * - One-shot mode: use --session-info flag to print resume line on exit
 *
 * Uses process.on('exit') instead of session_shutdown to avoid
 * printing for every session on exit (session_shutdown fires per
 * session switch too, not just final exit).
 */

import {
  copyToClipboard,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";

// Store state on globalThis so it survives module re-evaluation.
// When pi does /new, it re-evaluates extensions, creating new module-level
// variables. The exit handler (registered once via Symbol) would still
// reference the old variables. Using globalThis ensures the handler
// always reads the latest values.
const STATE_KEY = Symbol.for("pi:session-info:state");
const globalAny = globalThis as Record<symbol, { sessionId: string | undefined; hasUI: boolean | undefined }>;

if (!globalAny[STATE_KEY]) {
  globalAny[STATE_KEY] = { sessionId: undefined, hasUI: undefined };
}
const state = globalAny[STATE_KEY];

// Register exit handler exactly once using a global Symbol key.
const EXIT_HANDLER_KEY = Symbol.for("pi:session-info:exitHandler");
const globalFn = globalThis as Record<symbol, () => void>;

if (!globalFn[EXIT_HANDLER_KEY]) {
  const handler = () => {
    if (!state.sessionId) return;
    // Interactive/RPC mode: print resume line
    if (state.hasUI) {
      process.stderr.write(`continue with: pi --session ${state.sessionId}\n`);
    }
  };
  globalFn[EXIT_HANDLER_KEY] = handler;
  process.on("exit", handler);
}

export default function copySessionIdExtension(pi: ExtensionAPI) {

  // --session-info flag for one-shot mode
  pi.registerFlag("session-info", {
    description:
      "Print session resume info to stderr on exit (for one-shot mode)",
    type: "boolean",
    default: false,
  });

  pi.on("session_start", (_event, ctx) => {
    state.sessionId = ctx.sessionManager.getSessionId();
    state.hasUI = ctx.hasUI;
  });

  // One-shot mode: print resume info on shutdown if --session-info flag is set
  pi.on("session_shutdown", async (_event, ctx) => {
    if (!pi.getFlag("session-info")) return;

    const sessionId = ctx.sessionManager.getSessionId();
    if (!sessionId) return;

    process.stderr.write(
      `[pi] continue with: pi --session ${sessionId} -p "your follow-up"\n`,
    );
  });

  pi.registerShortcut("ctrl+;", {
    description: "Copy current session ID to clipboard",
    handler: async (ctx) => {
      const sm = ctx.sessionManager;
      const sessionId = sm.getSessionId();

      if (!sessionId) {
        ctx.ui.notify("No active session ID", "error");
        return;
      }

      await copyToClipboard(sessionId);
      ctx.ui.notify(`Copied session ID: ${sessionId}`, "success");
    },
  });
}
