# Declarative agent stack: per-agent selection and a uniform catalog

Date: 2026-10-03
Status: approved in conversation, awaiting written-spec review

## Goal

anikonistack is a home-manager module meant mainly for other people, which its author also uses to reproduce their own setup. A user should declare, in one readable place, which agents they run and which skills, plugins, commands, rules and subagents each agent gets. The same `flake.lock` must produce the same files on any machine.

## Problems with the current layout

1. Four shapes for one idea: skill groups, `plugins`, `claudePlugins` and a special `spartan` block, each wired differently in `module.nix`.
2. About 160 lines of hand-kept Spartan name lists in `skills.nix`.
3. No way to drop one skill. The author's NixOS config overrides the `skills` option on four programs to remove `resolving-merge-conflicts`.
4. Adapters hard-code policy: `codex.nix` and `opencode.nix` each list which plugins load natively.
5. Every agent adapter is always enabled, and MCP integration is switched on per agent in `mcp.nix`.
6. Personal choices sit in the shared module: Claude model, effort, permissions, MCP servers, and the `gh nodejs starship` packages.
7. Bundles are on or off for all agents at once.

## Decisions

- Audience: shared module with neutral defaults. Personal choices move to the user's own home-manager config.
- Defaults: opt-in. Importing the module and setting nothing writes no files.
- Declaration shape: one shared bundle list and skip list, inherited by each agent, replaceable per agent.
- Scope: structure only. Porting commands, rules and subagents to non-Claude agents is a later change to adapters only.
- No test suite. A one-time before/after comparison verifies the author's migration.

## User interface

```nix
anikonistack = {
  bundles = [ "custom" "mattpocock" "superpowers" "caveman" "spartan-core" "spartan-backend-micronaut" ];
  skip    = [ "resolving-merge-conflicts" ];

  agents = {
    claude-code = {
      enable = true;
      statusline = true;
    };
    codex.enable = true;
    cursor = {
      enable  = true;
      bundles = [ "custom" "superpowers" ];
    };
  };
};
```

Options:

| option | type | default | meaning |
|---|---|---|---|
| `anikonistack.bundles` | list of bundle names | `[]` | bundles every enabled agent gets unless it sets its own |
| `anikonistack.skip` | list of names | `[]` | single skills, commands, rules or subagents removed after merging |
| `anikonistack.agents.<agent>.enable` | bool | `false` | write this agent's config |
| `anikonistack.agents.<agent>.bundles` | list of bundle names | `anikonistack.bundles` | replaces the shared list for this agent |
| `anikonistack.agents.<agent>.skip` | list of names | `anikonistack.skip` | replaces the shared skip list for this agent |
| `anikonistack.agents.claude-code.statusline` | bool | `false` | install `hooks/statusline.sh` and point `settings.statusLine` at it |

Rules:

- Bundle names are checked by an `enum` type built from the catalog. A typo fails evaluation and lists the valid names.
- A `skip` name that matches nothing in the catalog fails an assertion.
- Selecting a bundle also selects everything in its `depends`, transitively.
- Each enabled agent sets `enableMcpIntegration = true` (Cursor writes `~/.cursor/mcp.json`). MCP servers come from the user's own `programs.mcp.servers`.
- Agent packages are not pinned. Each agent uses its home-manager default unless the user sets `programs.<agent>.package`.

## Catalog

Every bundle is an attrset with the same optional fields:

```nix
{
  description = "Kotlin + Micronaut backend";
  depends   = [ "spartan-database" "spartan-shared-backend" ];
  skills    = { <name> = <path>; };
  plugin    = <path>;                          # plugin dir in Claude Code layout
  native    = { <agent> = <path>; };           # this plugin's own loader for an agent
  commands  = { <name> = <path>; };
  rules     = { <name> = <path>; };
  subagents = { <name> = <path>; };
  context   = [ <text> ];                      # CLAUDE.md / AGENTS.md sections
}
```

- `native.claude-code` defaults to `plugin`, so Claude Code loads every plugin natively.
- For any other agent, a plugin without a `native.<agent>` entry contributes its `skills/` directory, flattened.
- A plugin with no `skills/` directory (duet) contributes nothing to agents that cannot load it natively. The separate `claudePlugins` category is removed.

Files:

```
catalog/
  default.nix    merges the files below into { <bundle> = <bundle attrset>; }
  custom.nix     bundle `custom`: skills/ and claude-md/ of this repo
  mattpocock.nix
  obsidian.nix
  extras.nix
  plugins.nix    superpowers, firecrawl, frontend-design, caveman, ponytail,
                 understand-anything, last30days, duet; with native entries
  spartan.nix    one bundle per upstream pack
```

The repo's own `claude-md/*.md` sections move into the `custom` bundle's `context`, so they are no longer always on.

### Spartan packs

Spartan ships `toolkit/packs/*.yaml`, one file per pack, each listing `commands`, `rules`, `skills`, `agents`, `claude-sections` and `depends`. `catalog/spartan.nix` turns each pack into a bundle named `spartan-<pack>`, with `depends` prefixed the same way.

- `lib/pack.nix` reads the YAML subset these files use: `key: value`, `key: []`, and `key:` followed by `  - item` lines. It runs in pure Nix, with no import-from-derivation. An unexpected line fails evaluation with the pack file name.
- Packs marked `coming-soon: true` are skipped.
- `spartan-core` also carries what Spartan's installer always adds: the `commands/spartan.md` router command and the `00-header`, `01-core` and `90-footer` CLAUDE.md sections.
- Commands are named `spartan/<name>`, as today.

## Module internals

```
module.nix         options, per-agent resolution, assertions; imports agents/
lib/resolve.nix    bundle list → depends closure (lib.genericClosure) → merge each kind → apply skip
lib/pack.nix       Spartan pack reader
catalog/
agents/
  default.nix
  claude-code.nix  codex.nix  opencode.nix  antigravity.nix  cursor.nix
```

`anikonistack.for "<agent>"` returns:

```nix
{
  plugins   = [ <path> ];          # native loaders for this agent
  skills    = { <name> = <path>; };  # bundle skills + flattened skills of non-native plugins
  commands  = { ... };
  rules     = { ... };
  subagents = { ... };
  context   = [ <text> ];          # in bundles-list order, then file name order within a bundle
}
```

The module argument is renamed from `agents` to `anikonistack`.

An adapter:

```nix
{ config, lib, anikonistack, ... }: let
  s = anikonistack.for "codex";
in lib.mkIf config.anikonistack.agents.codex.enable {
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    plugins = s.plugins;
    inherit (s) skills;
  };
}
```

- Agent-specific options are declared in that agent's adapter (for example `statusline` in `claude-code.nix`).
- An adapter reads only the kinds its agent supports; other kinds are dropped without a warning. The README documents which kinds each agent takes.
- Adding an agent stays one adapter file plus one import.

Assertions, per enabled agent:

- the same name supplied by two selected bundles, within one kind, fails and names both bundles;
- unknown `skip` names fail (checked against the whole catalog);
- the old `anikonistack.bundles.<name>.enable` form fails with a migration message (see below).

## Migration

- `anikonistack.bundles` accepts either a list or the old attrset form. The attrset form fails an assertion: "anikonistack.bundles.<name>.enable was removed. Use `anikonistack.bundles = [ … ]` and `anikonistack.agents.<name>.enable`. See the README."
- `mcp.nix` leaves the repo. Its servers move to the author's config.
- The `claude-code-nix` flake input is removed.
- The author's `~/nixos/home-manager/programs/agents.nix` is rewritten in a separate commit in that repo:
  - all current bundles selected, with `skip = [ "resolving-merge-conflicts" ]`, replacing the four-program `skills` override;
  - all five agents enabled, `claude-code.statusline = true`;
  - MCP servers, Claude model/effort/permissions and `gh nodejs starship` moved in from the repo.
- Verification: the generated `home.file` set and `CLAUDE.md` are compared before and after. They must match, except for differences listed in advance.

## Docs

README sections rewritten: How it works, Choosing bundles, Adding an agent, Adding content, Layout. New: a bundle table (name, description, kinds), an agent table (which kinds each agent takes), and an Upgrading note for the breaking change.

## Out of scope

- Porting commands, rules and subagents to codex, opencode and cursor.
- Global rules for Cursor.
- A test suite.
