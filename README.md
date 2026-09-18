# anikonistack

My reproducible Claude Code stack — skills, status line, hooks, and a home-manager module that declares the whole `~/.claude`.

## What's in it

```
anikonistack/
├── skills/     # my own custom skills: eli5, coursera-notes, course-quiz, commit, pr-review, issue-fix, theme-migrate, ...
├── hooks/      # statusline.sh (enabled-plugin badges)
├── claude-md/  # own CLAUDE.md sections (Spartan sections are pulled from upstream at build time)
├── home-manager.nix          # module entry for shared skills + plugin sources, imports the four below
├── claude-code.nix           # settings, CLAUDE.md, plugins, MCP servers
├── codex.nix, opencode.nix, antigravity.nix
├── flake.nix   # pins claude-code + every upstream skill/plugin repo
└── setup.sh    # non-nix fallback: symlinks skills/hooks into ~/.claude
```

## Install (NixOS / home-manager)

```nix
# flake.nix
inputs.anikonistack.url = "github:kidskoding/anikonistack";

# home.nix
imports = [ inputs.anikonistack.homeManagerModules.default ];
```

```bash
nix flake lock --update-input anikonistack
home-manager switch --flake .#<user>
```

One `switch` gives you: settings.json, CLAUDE.md, all skills (own + mattpocock
+ Spartan), Spartan commands/rules/agents, statusline, MCP servers, and the
plugins (superpowers, firecrawl, frontend-design, caveman, ponytail, duet,
understand-anything, last30days) as personal plugins. The same skills and
plugins are wired into Codex, OpenCode and Antigravity. No `/plugin install`,
no `npx skills add`, no `npx @c0x12c/ai-toolkit`.

The `claude` binary comes from [sadjow/claude-code-nix](https://github.com/sadjow/claude-code-nix),
not nixpkgs. Override with `programs.claude-code.package = ...;` if you want another source.

Update upstreams: `nix flake update` in this repo, commit `flake.lock`, then
`nix flake lock --update-input anikonistack` in your home-manager repo.
Spartan is pinned to a release tag in `flake.nix`; bump the tag by hand.

First build may fail on a mattpocock skill path if a skill moved folders
upstream (engineering / in-progress / deprecated). Fix the path in
`home-manager.nix`.

## Install (no nix)

```bash
git clone https://github.com/kidskoding/anikonistack.git
cd anikonistack
./setup.sh
```

`setup.sh` symlinks the skills and hooks into `~/.claude/`. It does **not**
touch your `~/.claude/settings.json` — configure model, status line, and
permissions there yourself.

To use `statusline.sh`, point your `settings.json` at it:

```json
"statusLine": { "type": "command", "command": "bash \"$HOME/.claude/hooks/statusline.sh\"" }
```
