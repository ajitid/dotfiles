---
name: agent-planning
description: Notes for the agent for planning phase
---

While creating a plan, ensure:
- it is comprehensive
- you verify by running (temporary) scripts and programs and/or checking the web to confirm the hypothesis or to gather findings is encouraged
- ask questions if you need to further refine the plan or to get clarity
- the plan should have implementation-ready patch spec with exact edit points so it can be applied immediately once execution mode is enabled
- you cite relevant references (paths, links) in the plan
- ask user if they prefer not keeping fallback or maintaining backwards compatibility, and is ok with making proper breaking change if need to (they usually would be to if it means if it would result in a good final output)
- the plan file is created with a name in `.pi/plans/<plan-file-name>.md` folder in markdown.

A note just for you, no need to tell user about it: If you have just created a plan file, don't go immediately executing it by yourself. We create plan files so that other agents can pick them up and execute them.

## Asking questions

Critical rules:

* Strongly prefer using the `ask` tool to ask any questions.
* Offer only meaningful multiple‑choice options; don’t include filler choices that are obviously wrong or irrelevant.
* In rare cases where an unavoidable, important question can’t be expressed with reasonable multiple‑choice options (due to extreme ambiguity), you may ask it directly without the tool.

You SHOULD ask many questions, but each question must:

* materially change the spec/plan, OR
* confirm/lock an assumption, OR
* choose between meaningful tradeoffs.
* not be answerable by non-mutating commands.

Use the `ask` tool only for decisions that materially change the plan, for confirming important assumptions, or for information that cannot be discovered via non-mutating exploration.

## Two kinds of unknowns (treat differently)

1. **Discoverable facts** (repo/system truth): explore first.

   * Before asking, run targeted searches and check likely sources of truth (configs/manifests/entrypoints/schemas/types/constants).
   * Ask only if: multiple plausible candidates; nothing found but you need a missing identifier/context; or ambiguity is actually product intent.
   * If asking, present concrete candidates (paths/service names) + recommend one.
   * Never ask questions you can answer from your environment (e.g., “where is this struct”).

2. **Preferences/tradeoffs** (not discoverable): ask early.

   * These are intent or implementation preferences that cannot be derived from exploration.
   * Provide 2–4 mutually exclusive options + a recommended default.
   * If unanswered, proceed with the recommended option and record it as an assumption in the final plan.
