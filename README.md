# anikonistack

a declarative and reproducible setup for all of your coding agents!

all of your skills, plugins and MCP servers are declared once, grouped into bundles you switch on and off; each agent gets a small adapter file that maps them onto that agent's config format. Add an agent, it gets the whole stack. Add a skill, and every agent you want gets it

## How it works

```
skills.nix ─┐
mcp.nix    ─┴─► module.nix ─► agents/*.nix, one per agent ─► ~/.<agent>/…
                (enabled bundles    claude-code.nix, codex.nix, …
                 → agents arg)
```

- `skills.nix`: everything the agents get, pinned via flake inputs. Four sections:
  - `skills`: groups of plain skills (`own` = `skills/`, `mattpocock`, `obsidian`, `extras`). Every agent gets them.
  - `plugins`: plugins in Claude Code layout. Agents with a native plugin mechanism load them; others get the plugin's `skills/` flattened in.
  - `claudePlugins`: plugins only Claude Code gets.
  - `spartan`: the Spartan toolkit. Skills for every agent; commands, rules, subagents and CLAUDE.md sections for Claude Code.

  Every group and every plugin is a bundle, toggled by `anikonistack.bundles.<name>.enable` (on by default).
- `mcp.nix`: `programs.mcp.servers`. home-manager translates each server into every agent's own format.
- `module.nix`: declares the bundle options, merges the enabled bundles into the `agents` module argument, and imports `agents/`. Your own `claude-md/*.md` always go first in CLAUDE.md. Evaluation fails if two enabled bundles define the same skill, plugin, command, rule or subagent name.
- `agents/`: one adapter per agent, listed in `agents/default.nix`.
- `flake.nix` + `flake.lock`: every upstream repo pinned to a commit. Same lock, same result, any machine.

Adapters currently in the repo are the agents I use. They are examples of the pattern, not the scope.

## Install

Requires [nix (the package manager!)](https://nixos.org/download) with flakes enabled! Nix runs on NixOS, any Linux, macOS, and WSL; NixOS itself is not required!

Since this is also a [home-manager](https://nix-community.github.io/home-manager/) module, [home-manager](https://nix-community.github.io/home-manager/) is also necessary in order to reproduce this setup!

1. install [nix (the package manager!)](https://nixos.org/download)
2. then `nix run home-manager -- init` to get a starter `flake.nix` and `home.nix`, then continue below

```nix
# flake.nix
inputs.anikonistack.url = "github:kidskoding/anikonistack";

# home.nix
imports = [ inputs.anikonistack.homeManagerModules.default ];
```

```bash
nix flake lock --update-input anikonistack
home-manager switch --flake .   # or nixos-rebuild switch
```

Every agent config under `$HOME` becomes a read-only symlink into the nix store, rebuilt from the pinned inputs.

## Choosing bundles

Every bundle is on by default. Turn off what you don't want, per machine, in your own home-manager config:

```nix
anikonistack.bundles = {
  spartan.enable = false;
  caveman.enable = false;
};
```

Disabling a plugin bundle removes it from every agent, whether that agent loads it natively or flattens its skills.

## Adding an agent

One file. Take the `agents` argument, feed it into whatever the agent's home-manager module accepts.

```nix
# agents/myagent.nix
{ agents, ... }:
{
  programs.myagent = {
    enable = true;
    skills = agents.skills // agents.pluginSkills (builtins.attrNames agents.plugins);
    enableMcpIntegration = true;
  };
}
```

Then add `./myagent.nix` to `imports` in `agents/default.nix`.

What `agents` gives you:

| field | what |
|---|---|
| `skills` | skills of enabled bundles, `name -> path` |
| `plugins` | plugins of enabled bundles that work outside Claude Code, `name -> path` |
| `pluginSkills [ names ]` | the `skills/` of those plugins, merged; disabled ones are skipped |
| `claude` | Claude Code extras: `plugins` (all), `commands`, `rules`, `agents`, `context` (list of CLAUDE.md sections, in bundle name order) |
| `skillDirs dir` | scan a directory for `*/SKILL.md` |
| `statusline` | wrapped `hooks/statusline.sh` with its runtime deps |
| `inputs` | the flake inputs, for adapters that need a pinned repo directly |

## Adding content

| what | where |
|---|---|
| a skill you wrote | dir with `SKILL.md` under `skills/` |
| an upstream skill | flake input, one line in a group in `skills.nix` |
| a plugin | flake input, one line under `plugins` in `skills.nix` |
| an MCP server | one entry in `mcp.nix` |

Secrets never go in the repo. Reference them as `${VAR}` in `mcp.nix` and export the variable before launching.

## Machine-specific config

Lives in your own home-manager config, not here: trusted directories, which package provides a binary, per-machine context.

```nix
programs.claude-code.package = null;   # binary already installed another way
```

## Updating

```bash
nix flake update                             # here, commit flake.lock
nix flake lock --update-input anikonistack   # in your home-manager repo
```

## Layout

```
anikonistack/
├── flake.nix          pins every upstream repo
├── module.nix         bundle options, merge, module entry
├── skills.nix         skills, plugins, spartan
├── mcp.nix            MCP servers
├── agents/            one adapter per agent
├── skills/            own skills
├── hooks/             statusline.sh
└── claude-md/         own CLAUDE.md sections
```
