# anikonistack

a declarative and reproducible setup for all of your coding agents!

all of your skills, plugins and MCP servers are declared once, grouped into bundles. You pick the agents you use and the bundles each one gets; a small adapter per agent maps them onto that agent's config format. Add an agent, and it can take the whole stack. Add a skill, and every agent you choose gets it

## How it works

```
catalog/*.nix ─► lib/resolve.nix ─► agents/*.nix, one per agent ─► ~/.<agent>/…
(every bundle)   (your bundles +     claude-code.nix, codex.nix, …
                  skips, per agent)
```

- `catalog/`: every bundle, pinned via flake inputs. A bundle is one attrset with the same optional fields everywhere: `skills`, `plugin` (a plugin dir in Claude Code layout), `native` (the plugin's own loader file per agent), `commands`, `rules`, `subagents`, `scripts`, `context` (CLAUDE.md sections) and `depends`.
- `catalog/spartan.nix`: one bundle per [Spartan](https://github.com/c0x12c/ai-toolkit) pack, read from the toolkit's own `packs/*.yaml` by `lib/pack.nix`. A Spartan update brings its new commands in without edits here.
- `lib/resolve.nix`: turns one agent's bundle list into its content. It adds `depends`, loads a plugin natively when the bundle has a `native` entry for that agent, flattens the plugin's `skills/` in otherwise, and removes `skip` names.
- `module.nix`: the options, the assertions, and the `anikonistackLib` module argument (`anikonistackLib.for "<agent>"`) that adapters read.
- `agents/`: one adapter per agent, listed in `agents/default.nix`. Each writes nothing unless `anikonistack.agents.<agent>.enable` is set.
- `flake.nix` + `flake.lock`: every upstream repo pinned to a commit. Same lock, same result, any machine. `nix flake check` reads the whole catalog and fails if any path it points at is missing, so a lock bump that breaks a bundle fails CI first.

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

anikonistack = {
  bundles = [ "custom" "superpowers" "spartan-core" ];
  agents.claude-code.enable = true;
};
```

```bash
nix flake lock --update-input anikonistack
home-manager switch --flake .   # or nixos-rebuild switch
```

Every agent config under `$HOME` becomes a read-only symlink into the nix store, rebuilt from the pinned inputs.

## Choosing agents and bundles

Nothing is on by default. Pick bundles once; every enabled agent gets them unless it sets its own list:

```nix
anikonistack = {
  bundles = [ "custom" "mattpocock" "superpowers" "caveman" "spartan-core" "spartan-backend-micronaut" ];
  skip    = [ "resolving-merge-conflicts" ];   # single skills, commands, rules or subagents

  agents = {
    claude-code = {
      enable = true;
      statusline = true;                       # hooks/statusline.sh
    };
    codex.enable = true;
    cursor = {
      enable = true;
      bundles = [ "custom" "superpowers" ];    # replaces the list above for cursor only
    };
  };
};
```

- A misspelled bundle name fails evaluation and lists the valid names. An unknown `skip` name fails too.
- `skip` also settles a clash: skip the name and neither bundle provides it.
- A plugin an agent loads natively is installed whole, so skipping one of its skills only works for agents that flatten it. For the others you get a warning; leave out the plugin's bundle instead.
- Choosing a bundle also brings in its `depends`.
- Evaluation fails if two bundles an agent gets define the same name, of the same kind, pointing at different files.
- MCP servers are yours: set `programs.mcp = { enable = true; servers = { … }; };` and every enabled agent picks them up. Without `enable = true`, home-manager gives the agents no servers.

### Bundles

| bundle | what | contains | depends on |
|---|---|---|---|
| `caveman` | terse caveman-style output | plugin, skills |  |
| `custom` | this repo's own skills and CLAUDE.md sections | skills, context |  |
| `duet` | claude-duet commands (Claude Code only) | plugin |  |
| `extras` | single skills from assorted repos | skills |  |
| `firecrawl` | Firecrawl web scraping and search | plugin, skills |  |
| `frontend-design` | Anthropic's frontend-design plugin | plugin, skills |  |
| `last30days` | research what happened in the last 30 days | plugin, skills |  |
| `mattpocock` | Matt Pocock's engineering and productivity skills | skills |  |
| `obsidian` | kepano's Obsidian skills | skills |  |
| `ponytail` | ponytail plugin | plugin, skills |  |
| `spartan-backend-micronaut` | Kotlin + Micronaut backend | skills, commands, rules, subagents, context | `spartan-core`, `spartan-database`, `spartan-shared-backend` |
| `spartan-core` | Core workflow (always installed) | commands, rules, subagents, context |  |
| `spartan-database` | Database patterns, migrations, Exposed ORM | skills, commands, rules, context | `spartan-core` |
| `spartan-frontend-react` | React + Next.js frontend | skills, commands, rules, context | `spartan-core` |
| `spartan-infrastructure` | Terraform + AWS infrastructure | skills, commands, rules, subagents, context | `spartan-core` |
| `spartan-ops` | Deploy & infrastructure | skills, commands, context | `spartan-core` |
| `spartan-product` | Product thinking before building | skills, commands, context | `spartan-core` |
| `spartan-research` | Startup research pipeline — from idea to investor-ready | skills, commands, subagents, context | `spartan-core`, `spartan-product` |
| `spartan-shared-backend` | Shared backend architecture concepts | rules | `spartan-core` |
| `spartan-ux-design` | UX design workflow — research, define, ideate, design system, prototype, test, AI asset generation | skills, commands, rules, subagents, scripts, context | `spartan-core` |
| `superpowers` | obra's superpowers workflow skills | plugin, skills |  |
| `understand-anything` | codebase knowledge graphs | plugin, skills |  |

`plugin` means agents with a native loader for it load the whole plugin; the others get its `skills/`.

### Agents

| agent | takes |
|---|---|
| `claude-code` | plugins, skills, commands, rules, subagents, scripts (`~/.claude/scripts`), context; optional `statusline` |
| `codex` | native plugins (caveman, ponytail, superpowers, last30days), skills |
| `opencode` | native plugins (ponytail, superpowers), skills |
| `antigravity` | skills |
| `cursor` | skills, `~/.cursor/mcp.json` |

Kinds an agent does not take are left out for that agent.

## Adding an agent

One file. Read `anikonistackLib.for "<agent>"` and feed it into whatever the agent's home-manager module accepts:

```nix
# agents/myagent.nix
{ anikonistackLib, config, lib, ... }: let
  s = anikonistackLib.for "myagent";
in {
  config = lib.mkIf config.anikonistack.agents.myagent.enable {
    programs.myagent = {
      enable = true;
      enableMcpIntegration = true;
      inherit (s) skills;
    };
  };
}
```

Add `./myagent.nix` to `imports` in `agents/default.nix` and `"myagent"` to `agentNames` in `module.nix`.

`anikonistackLib.for "<agent>"` returns:

| field | what |
|---|---|
| `plugins` | `{ <bundle> = <path>; }`, the plugins this agent loads natively |
| `skills` | `{ <name> = <path>; }`, bundle skills plus flattened skills of the other plugins |
| `commands`, `rules`, `subagents`, `scripts` | `{ <name> = <path>; }` |
| `context` | list of CLAUDE.md sections, in key order |

Agent-specific options go in the adapter, like `statusline` in `agents/claude-code.nix`.

## Adding content

| what | where |
|---|---|
| a skill you wrote | dir with `SKILL.md` under `skills/` (bundle `custom`) |
| an upstream skill | flake input, one line in a `catalog/*.nix` bundle |
| a plugin | flake input, one bundle in `catalog/plugins.nix`; add `native.<agent>` if the plugin ships a loader for that agent |
| a new group | a new `catalog/<name>.nix`, listed in `catalog/default.nix` |

Secrets never go in the repo. Reference them as `${VAR}` in `programs.mcp.servers` and export the variable before launching.

## Machine-specific config

Lives in your own home-manager config, not here: which agents and bundles, MCP servers, agent settings (model, permissions), which package provides a binary.

```nix
programs.claude-code.package = null;   # binary already installed another way
```

## Upgrading

Per-agent selection replaced the global toggles:

- `anikonistack.bundles.<name>.enable` is gone. List bundles instead: `anikonistack.bundles = [ … ]`. The old form fails with a message pointing here.
- Agents are opt-in: set `anikonistack.agents.<agent>.enable = true` for each one you use.
- Bundles were renamed: `own` → `custom`, `spartan` → `spartan-<pack>` (all of today's Spartan content is `spartan-core`, `spartan-database`, `spartan-shared-backend`, `spartan-backend-micronaut`, `spartan-frontend-react`, `spartan-ux-design`, `spartan-infrastructure`, `spartan-product`, `spartan-ops`, `spartan-research`).
- The repo no longer sets MCP servers, Claude Code settings or packages. Move whatever you relied on into your own config.

## Updating

```bash
nix flake update                             # here, commit flake.lock
nix flake lock --update-input anikonistack   # in your home-manager repo
```

## Layout

```
anikonistack/
├── flake.nix          pins every upstream repo
├── module.nix         options, assertions, module argument
├── catalog/           every bundle, one file per group
├── lib/               pack.nix (Spartan packs), resolve.nix, skill-dirs.nix
├── agents/            one adapter per agent
├── skills/            own skills (bundle `custom`)
├── hooks/             statusline.sh
└── claude-md/         own CLAUDE.md sections (bundle `custom`)
```
