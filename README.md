# anikonistack

A declarative, reproducible setup for coding agents. One flake pins every skill, plugin and MCP server; one `home-manager` module wires them into **Claude Code**, **Codex**, **OpenCode** and **Antigravity** at the same time.

```
anikonistack/
├── flake.nix          pins claude-code and every upstream skill / plugin repo
├── home-manager.nix   module entry, wires the files below together
├── skills.nix         every skill: own + mattpocock + spartan + others
├── plugins.nix        plugin sources
├── mcp.nix            MCP servers, shared by all agents
├── claude-code.nix    settings, CLAUDE.md, commands, rules, agents
├── codex.nix
├── opencode.nix
├── antigravity.nix
├── skills/            own skills (eli5, coursera-notes, course-quiz, commit, pr-review, ...)
├── hooks/             statusline.sh
├── claude-md/         own CLAUDE.md sections
└── setup.sh           non-nix fallback
```

## What you get

| | Claude Code | Codex | OpenCode | Antigravity |
|---|:---:|:---:|:---:|:---:|
| skills | ✓ | ✓ | ✓ | ✓ |
| plugins | 8 native | 4 native, rest as skills | 2 native, rest as skills | as skills |
| MCP servers | ✓ | ✓ | ✓ | ✓ |
| settings | ✓ | | | |
| CLAUDE.md, commands, rules, agents | ✓ | | | |
| statusline | ✓ | | | |

Plugins: superpowers, caveman, ponytail, duet, firecrawl, frontend-design, understand-anything, last30days.

Skills come from this repo's `skills/`, [mattpocock/skills](https://github.com/mattpocock/skills), the [Spartan AI Toolkit](https://github.com/c0x12c/ai-toolkit), and a few standalone repos. Add one in `skills.nix`, every agent gets it on the next switch.

## Install with home-manager

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

Machine-specific bits stay in your own config: trusted directories, auto-mode context, which package provides each binary.

```nix
programs.claude-code.package = null;   # already installed some other way
programs.codex.settings.projects."/path/to/repo".trust_level = "trusted";
```

The `claude` binary defaults to [sadjow/claude-code-nix](https://github.com/sadjow/claude-code-nix), which tracks releases faster than nixpkgs. Override with `programs.claude-code.package`.

## MCP servers

Declared once in `mcp.nix` via `programs.mcp.servers`; home-manager translates them for each agent.

| server | transport | needs |
|---|---|---|
| composio | http | nothing |
| github | http | `GITHUB_MCP_TOKEN` in the environment |
| playwright | stdio | `PLAYWRIGHT_MCP_EXTENSION_TOKEN` in the environment |

## Updating

```bash
nix flake update          # in this repo, then commit flake.lock
nix flake lock --update-input anikonistack   # in your home-manager repo
```

Spartan is pinned to a release tag in `flake.nix`, bump by hand. If a mattpocock skill moves folders upstream, the build fails on that path; fix it in `skills.nix`.

## Install without nix

```bash
git clone https://github.com/kidskoding/anikonistack.git
cd anikonistack && ./setup.sh
```

Symlinks `skills/` and `hooks/` into `~/.claude/`. Settings, plugins and upstream skills are not covered; install those by hand.

To use the status line, add to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "bash \"$HOME/.claude/hooks/statusline.sh\"" }
```
