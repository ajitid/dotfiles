/**
 * Desktop Notification Extension
 *
 * Sends a native desktop notification when the agent finishes and is waiting for input.
 * Also notifies when the agent asks a question via the "ask" tool (tool_call event);
 * agent_end alone would only fire after the question is answered and the run completes.
 * Uses OSC 777 escape sequence - no external dependencies.
 *
 * Supported terminals: Ghostty, iTerm2, WezTerm, rxvt-unicode
 * Not supported: Kitty (uses OSC 99), Terminal.app, Windows Terminal, Alacritty
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Markdown, type MarkdownTheme, stripTerminalSequences } from "@earendil-works/pi-tui";

/**
 * Send a desktop notification via OSC 777 escape sequence.
 */
const notify = (title: string, body: string): void => {
	// OSC 777 format: ESC ] 777 ; notify ; title ; body BEL
	process.stdout.write(`\x1b]777;notify;${title};${body}\x07`);
};

const isTextPart = (part: unknown): part is { type: "text"; text: string } =>
	Boolean(part && typeof part === "object" && "type" in part && part.type === "text" && "text" in part);

const extractLastAssistantText = (messages: Array<{ role?: string; content?: unknown }>): string | null => {
	for (let i = messages.length - 1; i >= 0; i--) {
		const message = messages[i];
		if (message?.role !== "assistant") {
			continue;
		}

		const content = message.content;
		if (typeof content === "string") {
			return content.trim() || null;
		}

		if (Array.isArray(content)) {
			const text = content.filter(isTextPart).map((part) => part.text).join("\n").trim();
			return text || null;
		}

		return null;
	}

	return null;
};

const plainMarkdownTheme: MarkdownTheme = {
	heading: (text) => text,
	link: (text) => text,
	linkUrl: () => "",
	code: (text) => text,
	codeBlock: (text) => text,
	codeBlockBorder: () => "",
	quote: (text) => text,
	quoteBorder: () => "",
	hr: () => "",
	listBullet: () => "",
	bold: (text) => text,
	italic: (text) => text,
	strikethrough: (text) => text,
	underline: (text) => text,
};

const simpleMarkdown = (text: string, width = 80): string => {
	const markdown = new Markdown(text, 0, 0, plainMarkdownTheme);
	return markdown.render(width).join("\n");
};

const clampNotificationBody = (text: string): string => {
	const normalized = text
		.replace(/[\x00-\x1f\x7f-\x9f]/g, " ")
		.replace(/\s+/g, " ")
		.trim();
	if (normalized.length > 200) {
		return `${normalized.slice(0, 199)}…`;
	}
	return normalized;
};

const extractAskBody = (input: Record<string, unknown>): string => {
	const questions = input.questions;
	if (!Array.isArray(questions) || questions.length === 0) {
		return "";
	}

	const firstQuestion = questions[0] as { question?: unknown } | undefined;
	const firstText = typeof firstQuestion?.question === "string" ? firstQuestion.question.trim() : "";
	const prefix = questions.length > 1 ? `${questions.length} questions: ` : "";
	return `${prefix}${firstText}`;
};

const formatNotification = (text: string | null): { title: string; body: string } => {
	const simplified = text ? simpleMarkdown(text) : "";
	// Markdown emits OSC 8 hyperlinks. Embedding one OSC sequence inside the OSC
	// 777 notification terminates the notification early and prints its visible
	// text at the terminal cursor. Remove terminal sequences and remaining control
	// characters before constructing the outer OSC sequence.
	const normalized = stripTerminalSequences(simplified)
		.replace(/[\x00-\x1f\x7f-\x9f]/g, " ")
		.replace(/\s+/g, " ")
		.trim();
	if (!normalized) {
		return { title: "Ready for input", body: "" };
	}

	const maxBody = 200;
	const body = normalized.length > maxBody ? `${normalized.slice(0, maxBody - 1)}…` : normalized;
	return { title: "π", body };
};

export default function (pi: ExtensionAPI) {
	pi.on("agent_end", async (event) => {
		const lastText = extractLastAssistantText(event.messages ?? []);
		const { title, body } = formatNotification(lastText);
		notify(title, body);
	});

	// tool_call fires after argument validation and just before execute(), so it is the
	// accurate "the ask UI is about to appear" moment (tool_execution_start fires earlier,
	// before validation and blocking handlers).
	pi.on("tool_call", (event) => {
		if (event.toolName !== "ask") {
			return;
		}

		notify("π — question", clampNotificationBody(extractAskBody(event.input)));
	});
}
