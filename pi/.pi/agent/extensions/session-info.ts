/**
 * Session Info Extension
 *
 * - Ctrl+; copies the current session ID to clipboard
 * - One-shot mode: use --session-info flag to print resume line on exit
 *
 * Interactive-mode exit printing is handled by pi itself.
 */

import {
  copyToClipboard,
  type ExtensionAPI,
} from "@mariozechner/pi-coding-agent";

const STATE_KEY = Symbol.for("pi:session-info:state");
const globalState = globalThis as Record<
  symbol,
  { pendingExitMessage?: string; printedExitMessage?: boolean }
>;

if (!globalState[STATE_KEY]) {
  globalState[STATE_KEY] = {};
}
const state = globalState[STATE_KEY];

function printPendingExitMessage() {
  if (!state.pendingExitMessage || state.printedExitMessage) return;
  state.printedExitMessage = true;
  process.stderr.write(state.pendingExitMessage);
}

const EXIT_HANDLER_KEY = Symbol.for("pi:session-info:exitHandler");
const globalHandlers = globalThis as Record<symbol, true>;

if (!globalHandlers[EXIT_HANDLER_KEY]) {
  globalHandlers[EXIT_HANDLER_KEY] = true;
  process.on("beforeExit", printPendingExitMessage);
  process.on("exit", printPendingExitMessage);
}

export default function copySessionIdExtension(pi: ExtensionAPI) {
  // --session-info flag for one-shot mode
  pi.registerFlag("session-info", {
    description:
      "Print session resume info to stderr on exit (for one-shot mode)",
    type: "boolean",
    default: false,
  });

  // One-shot mode: print resume info on shutdown if --session-info flag is set
  pi.on("session_shutdown", async (event, ctx) => {
    if (event.reason !== "quit") return;
    if (ctx.hasUI) return;
    if (!pi.getFlag("session-info")) return;

    const sessionId = ctx.sessionManager.getSessionId();
    if (!sessionId) return;

    state.pendingExitMessage = `[pi] continue with: pi --session ${sessionId} -p "your follow-up"\n`;
    state.printedExitMessage = false;
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
