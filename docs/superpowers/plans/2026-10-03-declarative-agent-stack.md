# Declarative Agent Stack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace global bundle toggles with an opt-in, per-agent declaration over a uniform bundle catalog.

**Architecture:** `catalog/*.nix` defines every bundle in one shape. `lib/resolve.nix` turns a bundle list plus skip list into one agent's content. `module.nix` declares the options, exposes `anikonistack.for "<agent>"` as a module argument, and runs the assertions. Each `agents/<agent>.nix` adapter maps that content onto its home-manager program, guarded by `anikonistack.agents.<agent>.enable`.

**Tech Stack:** Nix flakes, home-manager modules, alejandra.

**Spec:** `docs/superpowers/specs/2026-10-03-declarative-agent-stack-design.md`

## Global Constraints

- No test suite (user decision). Verification is `nix eval` / `nix flake check` / alejandra, plus the one-time before/after comparison in Task 1 and Task 7.
- Opt-in: every option defaults to empty or `false`. Importing the module with nothing set writes no files.
- Agent names, exactly: `claude-code`, `codex`, `opencode`, `antigravity`, `cursor`.
- Bundle names, exactly: `custom`, `mattpocock`, `obsidian`, `extras`, `superpowers`, `firecrawl`, `frontend-design`, `caveman`, `ponytail`, `understand-anything`, `last30days`, `duet`, and `spartan-<pack>` for every non-`coming-soon` pack.
- Module argument is named `anikonistack` (not `agents`).
- Pure evaluation: no import-from-derivation.
- Formatting: `nix run --inputs-from . nixpkgs#alejandra -- --check .` must pass before each commit.
- Commit messages: Conventional Commits, no `Co-Authored-By` trailer (user preference).
- `SCRATCH` below means `/tmp/claude-1000/-home-anirudh-anikonistack/bc96d589-a35b-4fb0-9a22-fc39d0bf0080/scratchpad`.

## Review Focus

- A user who sets `anikonistack.agents.cursor.enable = true` but no bundles: cursor gets `~/.cursor/mcp.json` only if `programs.mcp.servers` is non-empty, and no skills. No error.
- A skip name that exists in the catalog but not in this agent's selection (for example skipping a Spartan command for cursor): no error, nothing happens.
- Selecting both a plugin bundle and a skill group that ship the same skill name (`brainstorm` in spartan and superpowers' `brainstorming` are different; `research` exists in mattpocock and as a Spartan command, a different kind): only same-kind clashes fail.
- An old config with `anikonistack.bundles.spartan.enable = false;` must fail with the migration message, not a type error.
- A Spartan update that adds a new key or line form to a pack file must fail evaluation naming the pack file, not silently drop content.

Checked in: Task 4 Step 3 case 2; Task 4 Step 3 case 3; Task 7 Step 3 (real data, any new conflict fails evaluation); Task 4 Step 3 case 4; Task 2 Step 3.

---

### Task 1: Capture baseline

**Files:** none in repo. Writes `SCRATCH/before-file.json`, `SCRATCH/before-configFile.json`, `SCRATCH/before-claude.md`.

**Interfaces:**
- Produces: the three baseline files Task 7 compares against.

- [ ] **Step 1: Record the current commit**

Run: `git -C /home/anirudh/anikonistack rev-parse HEAD > $SCRATCH/before-rev`

- [ ] **Step 2: Dump generated files from the NixOS config at that commit**

Run, from `/home/anirudh/nixos`, with `REV=$(cat $SCRATCH/before-rev)`:
```bash
for attr in home.file xdg.configFile; do
  nix eval --no-write-lock-file \
    --override-input anikonistack "git+file:///home/anirudh/anikonistack?rev=$REV" \
    --json ".#nixosConfigurations.nixos.config.home-manager.users.anirudh.$attr" \
    --apply 'f: builtins.mapAttrs (_: v: toString v.source) f' \
    > "$SCRATCH/before-${attr#*.}.json"
done
```
Then `jq -r '.[".claude/CLAUDE.md"]' $SCRATCH/before-file.json | xargs cat > $SCRATCH/before-claude.md`.
Expected: both JSON files non-empty; `before-claude.md` starts with the eli5 section.

No commit.

### Task 2: Spartan pack reader

**Files:**
- Create: `lib/pack.nix`

**Interfaces:**
- Produces: `import ./lib/pack.nix {inherit lib;}` is a function `file -> attrset`. Scalars are strings with surrounding `"` removed (`hidden = "false"`, `"coming-soon" = "true"`). List keys map to lists of strings; `key: []` maps to `[]`.

- [ ] **Step 1: Implement `lib/pack.nix`**

Split the file on newlines, drop blank lines and `#` comments. A line `key: value` sets a scalar; `key:` with no value starts a list; `  - item` appends to the current list; `key: []` sets an empty list. Any other line throws `"anikonistack: unrecognised line in <file>: <line>"`. Fold with `lib.foldl'` carrying `{ current; result; }`.

- [ ] **Step 2: Verify against upstream core pack**

Run:
```bash
nix eval --impure --json --expr 'let f = builtins.getFlake (toString /home/anirudh/anikonistack); lib = (import <nixpkgs> {}).lib; p = import /home/anirudh/anikonistack/lib/pack.nix {inherit lib;} "${f.inputs.spartan}/toolkit/packs/core.yaml"; in { c = builtins.length p.commands; inherit (p) agents skills rules; }'
```
Expected: `{"agents":["phase-reviewer.md"],"c":29,"rules":["core/NAMING_CONVENTIONS.md","core/TIMEZONE.md","core/SKILL_AUTHORING.md"],"skills":[]}`

- [ ] **Step 3: Verify every pack parses and bad input throws**

Run the same expression mapped over every file in `packs/` (`builtins.readDir`); expected: no error, 12 names. Then evaluate the reader on a temp file containing `foo bar` and expect the `unrecognised line` error.

- [ ] **Step 4: Format and commit**

```bash
git add lib/pack.nix
git commit -m "feat(lib): add spartan pack reader"
```

### Task 3: Catalog

**Files:**
- Create: `catalog/default.nix`, `catalog/custom.nix`, `catalog/mattpocock.nix`, `catalog/obsidian.nix`, `catalog/extras.nix`, `catalog/plugins.nix`, `catalog/spartan.nix`
- Delete later (Task 5): `skills.nix`

**Interfaces:**
- Consumes: `lib/pack.nix` (Task 2).
- Produces: `import ./catalog {inherit inputs lib;}` → `{ <bundle> = { description; depends; skills; plugin; native; commands; rules; subagents; context; }; }` with every field present (defaults: `""`, `[]`, `{}`, `null`, `{}`, `{}`, `{}`, `{}`, `{}`). `context` is `{ <key> = <text>; }`. `catalog/default.nix` fills defaults and sets `native.claude-code = plugin` when `plugin != null` and no explicit entry exists. It also exports `skillDirs : dir -> { <name> = <path>; }` (moved from `module.nix`) by passing it to each catalog file.
- Each catalog file: `{ inputs, lib, skillDirs }: { <bundle> = { ...partial bundle... }; }`.

- [ ] **Step 1: Port non-Spartan content**

Move the entries from `skills.nix` verbatim:
- `custom.nix`: bundle `custom` with `skills = skillDirs ../skills;` and `context` = every file in `../claude-md`, keyed `00-custom/<file name>`.
- `mattpocock.nix`, `obsidian.nix`, `extras.nix`: one bundle each, same entries as today's `skills.mattpocock`, `skills.obsidian`, `skills.extras`.
- `plugins.nix`: one bundle per plugin with `plugin = <path as today>`; `duet` uses today's `claudePlugins.duet` path. `native` entries:
  - `caveman.native.codex = "${inputs.caveman}/plugins/caveman"`
  - `ponytail.native = { codex = inputs.ponytail; opencode = "${inputs.ponytail}/.opencode/plugins/ponytail.mjs"; }`
  - `superpowers.native = { codex = inputs.superpowers; opencode = "${inputs.superpowers}/.opencode/plugins/superpowers.js"; }`
  - `last30days.native.codex = inputs.last30days`

Give every bundle a one-line `description`.

- [ ] **Step 2: Implement `catalog/spartan.nix`**

For each `packs/*.yaml` not marked `"coming-soon" = "true"`, emit `spartan-<name>`:
- `description` from the pack; `depends` = pack `depends` prefixed `spartan-`.
- `skills.<n> = "${toolkit}/skills/<n>"`; `commands."spartan/<n>" = "${toolkit}/commands/spartan/<n>.md"`; `rules.<r without .md> = "${toolkit}/rules/<r>"`; `subagents.<a without .md> = "${toolkit}/agents/<a>"`; `context."50-spartan/<s>" = builtins.readFile "${toolkit}/claude-md/<s>"`.
- `spartan-core` additionally gets `commands.spartan = "${toolkit}/commands/spartan.md"` and context `00-header.md`, `01-core.md`, `90-footer.md`.

- [ ] **Step 3: Verify the catalog**

Run:
```bash
nix eval --impure --json --expr 'let f = builtins.getFlake (toString /home/anirudh/anikonistack); c = import /home/anirudh/anikonistack/catalog {inherit (f) inputs; lib = (import <nixpkgs> {}).lib;}; in { names = builtins.attrNames c; micronautDeps = c.spartan-backend-micronaut.depends; cavemanNative = builtins.attrNames c.caveman.native; }'
```
Expected: names include all 12 non-Spartan bundles and 10 `spartan-*` bundles (no `spartan-backend-nodejs`, no `spartan-backend-python`); `micronautDeps` = `["spartan-database","spartan-shared-backend"]`; `cavemanNative` = `["claude-code","codex"]`.

- [ ] **Step 4: Format and commit**

```bash
git add catalog
git commit -m "feat(catalog): define every bundle in one shape"
```

### Task 4: Resolver, options and assertions

**Files:**
- Create: `lib/resolve.nix`
- Modify: `module.nix` (full rewrite)

**Interfaces:**
- Consumes: catalog (Task 3).
- Produces:
  - `import ./lib/resolve.nix {inherit lib;}` → `{ catalog, agent, bundles, skip } -> { plugins = { <bundle> = <path>; }; skills; commands; rules; subagents; context = [ <text> ]; conflicts = [ <string> ]; }`.
  - Options: `anikonistack.bundles` (`either (listOf (enum <bundle names>)) (attrsOf anything)`, default `[]`), `anikonistack.skip` (`listOf str`, default `[]`), `anikonistack.agents.<agent>.{enable, bundles, skip}` for the five agent names, defaults `false` / top-level list (or `[]` if the top level is the old attrset) / top-level skip.
  - Module argument `anikonistack = { for = agent: <resolve result>; inputs; statusline = <exe path of wrapped hooks/statusline.sh>; }`.

- [ ] **Step 1: Implement `lib/resolve.nix`**

- Closure: `lib.genericClosure` over `bundles`, following `depends`.
- For each selected bundle: if `native.${agent}` exists, add it to `plugins`; otherwise, if `plugin != null`, merge `skillDirs "${plugin}/skills"` (only when that dir exists) into skills.
- Merge `skills`, `commands`, `rules`, `subagents`, `context` with `//`. Before merging, collect names that appear in more than one selected bundle within the same kind; each becomes a conflict string `"<kind> <name>: <bundle>, <bundle>"`.
- Remove every `skip` name from `skills`, `commands`, `rules`, `subagents`.
- `context` = `lib.attrValues` of the merged context attrset (key order).

- [ ] **Step 2: Rewrite `module.nix`**

Keep the `inputs: { config, lib, pkgs, ... }:` shape. Import `./agents` only (`./mcp.nix` goes away in Task 5). Assertions:
- old syntax: `builtins.isAttrs config.anikonistack.bundles` → message exactly: `anikonistack.bundles.<name>.enable was removed. Use anikonistack.bundles = [ … ] and anikonistack.agents.<name>.enable. See the README.`
- unknown skip: every name in top-level and per-agent `skip` must appear as a skill, command, rule or subagent name somewhere in the catalog; message `anikonistack: unknown skip name(s): <names>`.
- conflicts: for each enabled agent, `conflicts == []`; message `anikonistack (<agent>): <conflict lines>`.

- [ ] **Step 3: Verify Review Focus cases with a scratch config**

Write `SCRATCH/hm-eval.nix` that builds a home-manager configuration from the user's `~/nixos` flake's `home-manager` input and nixpkgs with: this module imported, `home.username`/`homeDirectory`/`stateVersion` set, and options passed in as an argument. Evaluate `config.assertions` (filtered to failures) and `config.home.file` names for:
1. nothing set → no `.claude`, `.codex`, `.cursor` files.
2. `agents.cursor.enable = true;` only → no failures, no `.cursor/skills`.
3. `bundles = ["custom"]; skip = ["spartan/build"]; agents.cursor.enable = true;` → no failures.
4. `bundles.spartan.enable = false;` → exactly the old-syntax message.
5. `skip = ["no-such-thing"];` → the unknown-skip message.
Expected: each result as stated.

- [ ] **Step 4: Format and commit**

```bash
git add lib/resolve.nix module.nix
git commit -m "feat: per-agent bundle selection with opt-in defaults"
```

### Task 5: Adapters and repo cleanup

**Files:**
- Modify: `agents/claude-code.nix`, `agents/codex.nix`, `agents/opencode.nix`, `agents/antigravity.nix`, `agents/cursor.nix`
- Delete: `skills.nix`, `mcp.nix`
- Modify: `flake.nix`, `flake.lock`

**Interfaces:**
- Consumes: `anikonistack.for`, `anikonistack.statusline`, `config.anikonistack.agents.<agent>` (Task 4).

- [ ] **Step 1: Rewrite each adapter**

Every adapter is `lib.mkIf config.anikonistack.agents.<agent>.enable { ... }` with `s = anikonistack.for "<agent>"`, and sets `enableMcpIntegration = true` (cursor keeps its own `mcp.json`):
- `claude-code`: `skills = s.skills; plugins = s.plugins; commands = s.commands; rules = s.rules; agents = s.subagents; context = lib.concatStringsSep "\n" s.context;`. Declares `options.anikonistack.agents.claude-code = lib.mkOption { type = lib.types.submodule { options.statusline = lib.mkEnableOption "the anikonistack statusline"; }; };` and, when set, `hooks."statusline.sh" = anikonistack.statusline;` plus today's `settings.statusLine`. Removes model, effort, theme, tui, permissions, env, package pin and `home.packages`.
- `codex`: `plugins = lib.attrValues s.plugins; skills = s.skills;`
- `opencode`: `settings.plugin = lib.attrValues s.plugins; skills = s.skills;`
- `antigravity`: `programs.antigravity-cli.skills = s.skills;`
- `cursor`: unchanged logic, skills from `s.skills`, whole config under `mkIf`.

- [ ] **Step 2: Remove repo-level personal config**

Delete `skills.nix` and `mcp.nix`. In `flake.nix`, remove the `claude-code-nix` input and add `nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";` (used only by the CI formatter, which previously reached nixpkgs through `claude-code-nix`). Run `nix flake lock`.

- [ ] **Step 3: Verify**

Run `nix flake check` and the alejandra check. Expected: both pass. Re-run Task 4's scratch case 1 and expect no agent files.

- [ ] **Step 4: Commit**

```bash
git add -A agents flake.nix flake.lock skills.nix mcp.nix
git commit -m "refactor(agents): adapters read per-agent content; move personal config out"
```

### Task 6: README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Rewrite sections**

Rewrite "How it works", "Choosing bundles", "Adding an agent", "Adding content" and "Layout" to match the spec. Add:
- a bundle table: name, description, kinds it contains (generate the Spartan rows from `catalog/spartan.nix` output);
- an agent table: `claude-code` takes plugins, skills, commands, rules, subagents, context; `codex` plugins, skills; `opencode` plugins, skills; `antigravity` skills; `cursor` skills and `mcp.json`;
- an "Upgrading" note: old `bundles.<name>.enable` → list form, agents now opt-in, MCP servers and agent settings now belong in the user's own config.

Replace the install example's config with the Section 1 example from the spec.

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs(readme): document per-agent declaration"
```

### Task 7: Migrate the author's NixOS config and compare

**Files:**
- Modify: `/home/anirudh/nixos/home-manager/programs/agents.nix` (separate repo)

**Interfaces:**
- Consumes: Task 1 baseline files; all options from Task 4–5.

- [ ] **Step 1: Rewrite `agents.nix`**

- Remove the `options.programs = lib.genAttrs [...]` skills override.
- Add `anikonistack.bundles` = every non-Spartan bundle plus `spartan-core spartan-database spartan-shared-backend spartan-backend-micronaut spartan-frontend-react spartan-ux-design spartan-infrastructure spartan-product spartan-ops spartan-research`; `anikonistack.skip = ["resolving-merge-conflicts"];`; all five agents enabled; `claude-code.statusline = true`.
- Move in, verbatim from the old repo files: `programs.mcp = { enable = true; servers = { … }; }` (from `mcp.nix`), and `programs.claude-code.settings` keys `model`, `modelSettings`, `effortLevel`, `theme`, `tui`, `skipWorkflowUsageWarning`, `agentPushNotifEnabled`, `env`, `permissions` (from old `claude-code.nix`), plus `home.packages = with pkgs; [gh nodejs starship];`.

- [ ] **Step 2: Dump the new state**

Repeat Task 1 Step 2 with `--override-input anikonistack path:/home/anirudh/anikonistack`, writing `after-file.json`, `after-configFile.json`, `after-claude.md`.

- [ ] **Step 3: Compare**

Run `diff <(jq -S . $SCRATCH/before-file.json) <(jq -S . $SCRATCH/after-file.json)`, the same for `configFile`, and `diff $SCRATCH/before-claude.md $SCRATCH/after-claude.md`.
Expected differences only:
- `.cursor/skills/resolving-merge-conflicts` removed (skip now covers cursor);
- Spartan files that packs include but the old hand lists did not (skills `ci-cd-patterns`, `service-debugging`, `ui-ux-pro-max` if their packs list them; rules `core/GIT_COMMIT`, `backend-micronaut/PERFORMANCE` if listed);
- store paths of generated files whose content changed only because of the above.
Report the exact list to the user before Step 4. Any other difference is a bug: fix it in the earlier task's file, then re-run this step.

- [ ] **Step 4: Commit in the nixos repo**

```bash
git -C /home/anirudh/nixos add home-manager/programs/agents.nix
git -C /home/anirudh/nixos commit -m "refactor(agents): declare anikonistack per agent"
```
Deploying (pushing anikonistack, `nix flake update anikonistack`, `nixos-rebuild switch`) is left to the user.
