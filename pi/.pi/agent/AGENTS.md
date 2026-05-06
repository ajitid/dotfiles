# Notes for the agent

## On asking

Please ask. Ask if you're unsure. Ask if there are multiple options all of which are good options to choose from. Asking is encouraged. You have `ask` tool with you.

## On self verifying

Verify by running (temporary) scripts and programs and/or checking the web to confirm the hypothesis or to gather findings is encouraged.

## On breaking changes

User doesn't necessarily want backwards compatibility and might be okay with breaking changes especially if it results in cleaner and better implementation. So don't assume and ask the user about it.

## On fallback-ing

User may prefer if the program immediately breaks and signals rather than relying on fallbacks or defaults. So don't assume and ask the user about it.

In a similar vein, adding or retaining a defensive extra is also not needed. If you see a defensive extra, mention it to the user.

## On when you're not being sure

When you're not sure if the fix/feature can be implemented, you can still attempt the fix. Just make sure the files you're going to change are already backed up in git if git repo is there, and if it isn't there then create a backup copy of them before you go start changing.

Also in these cases, tell the user that you're not sure.

## On creating the plan

For building the plan, read agent-planning skill.

## On executing/implementing the plan (aka plan implementation phase)

If you're not sure of something even after you have explored resources, please ask before you go start implementing.

Create todos in `.pi/todos/<plan-file-name>.md` with phases and ensure to check out items as you progress thorugh them.

If you are going to do planning instead, see the agent-planning skill.

## On increasing your capability

Sometimes you want to further inspect a problem but you don't have the necessary tools or internals available to you. In that case instead of making up and trying to solve the problem with only the tools you have and the internals knowledge you have gathered, you can ask the user to provide access to those tools and/or internals to you. You can tell them what you're missing and what you expect that tool/internals will provide. 

Do note that such tool may not exist yet or you may not have known about it. So it is fine to ask for such imaginary tool with certain capabilities. 

## Quick points

- Web page fetching order:
  1. If you have a dedicated skill to fetch then try that first
  2. Otherwise use `web_fetch` tool to fetch. You may need `web_fetch` with `--raw` if the output you're expecting is non-HTML. If `web_fetch` only gives you title and maybe meta description then, go with 3rd option which is...
  3. Use "Linkup: WebFetch" (`linkup_web_fetch`)
- WebSearch: only search for top 8 results
- Unless specified, prefer installing the latest package dependencies. For example use `bun add` and `cargo add` instead of directly modifying `package.json` or `Cargo.toml`.
