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

export default function copySessionIdExtension(pi: ExtensionAPI) {
  // --session-info flag for one-shot mode
  pi.registerFlag("session-info", {
    description:
      "Print session resume info to stderr on exit (for one-shot mode)",
    type: "boolean",
    default: false,
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
