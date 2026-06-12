import { resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function isHomeDir(cwd: string): boolean {
	const home = process.env.HOME;
	return home !== undefined && resolve(cwd) === resolve(home);
}

export default function (pi: ExtensionAPI) {
	pi.on("project_trust", (event) => {
		return { trusted: isHomeDir(event.cwd) ? "yes" : "undecided" };
	});
}
