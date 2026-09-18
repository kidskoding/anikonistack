# anikonistack

My reproducible Claude Code stack — skills, status line, hooks, and a home-manager module that declares the whole `~/.claude`.

## What's in it

```
anikonistack/
├── skills/     # own skills: eli5, coursera-notes, course-quiz, commit, pr-review, issue-fix, job-autofill, theme-migrate, ...
├── hooks/      # statusline.sh (enabled-plugin badges)
├── claude-md/  # own CLAUDE.md sections (Spartan sections are pulled from upstream at build time)
├── home-manager.nix          # module entry: shared skills + plugin sources, imports the four below
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
understand-anything, last30days) as personal plugins. No `/plugin install`,
no `npx skills add`, no `npx @c0x12c/ai-toolkit`.

The `claude` binary comes from [sadjow/claude-code-nix](https://github.com/sadjow/claude-code-nix),
not nixpkgs. Override with `programs.claude-code.package = ...;` if you want another source.

Secrets stay out of the repo. Export before launching `claude`:

```
GITHUB_MCP_TOKEN                # github MCP (api.githubcopilot.com)
PLAYWRIGHT_MCP_EXTENSION_TOKEN  # playwright MCP --extension
```

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

## Plugins

Install these separately (they self-wire their own hooks/skills):

```
/plugin marketplace add JuliusBrussee/caveman   && /plugin install caveman@caveman
/plugin marketplace add DietrichGebert/ponytail && /plugin install ponytail@ponytail
/plugin marketplace add bokuhe/claude-duet      && /plugin install duet@duet-marketplace
/plugin install superpowers@claude-plugins-official
```

- [superpowers](https://github.com/anthropics/claude-plugins) — skill framework
- [caveman](https://github.com/JuliusBrussee/caveman) — terse output mode
- [ponytail](https://github.com/DietrichGebert/ponytail) — laziest-solution mode
- [duet](https://github.com/bokuhe/claude-duet) — Gemini-assisted review/PR
