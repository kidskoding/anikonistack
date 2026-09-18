# anikonistack

A declarative, reproducible setup for coding agents. One flake pins every skill, plugin and MCP server; one `home-manager` module wires them into many coding agents at once!

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

## How it works

`skills.nix`, `plugins.nix` and `mcp.nix` are the single source of truth. Each agent is one small file that consumes them through the `agents` module argument. Add an agent, and it gets the whole stack; add a skill, and every agent gets it.

Agents wired so far are the ones I use. Any tool with a home-manager module fits the same pattern:

```nix
# myagent.nix
inputs:
{ agents, ... }:
{
  programs.myagent = {
    enable = true;
    skills = agents.skills // agents.pluginSkills [ "caveman" "superpowers" ];
    enableMcpIntegration = true;
  };
}
```

Then add `(import ./myagent.nix inputs)` to the imports in `home-manager.nix`.

| | Claude Code | Codex | OpenCode | Antigravity |
|---|:---:|:---:|:---:|:---:|
| skills | ✓ | ✓ | ✓ | ✓ |
| plugins | 8 native | 4 native, rest as skills | 2 native, rest as skills | as skills |
| MCP servers | ✓ | ✓ | ✓ | ✓ |
| settings | ✓ | | | |
| CLAUDE.md, commands, rules, agents | ✓ | | | |
| statusline | ✓ | | | |

Plugins: superpowers, caveman, ponytail, duet, firecrawl, frontend-design, understand-anything, last30days.

Skills come from this repo's `skills/`, [mattpocock/skills](https://github.com/mattpocock/skills), the [Spartan AI Toolkit](https://github.com/c0x12c/ai-toolkit), and a few standalone repos.

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
