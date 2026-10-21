# anikonistack

[![skills.sh](https://skills.sh/b/kidskoding/anikonistack)](https://skills.sh/kidskoding/anikonistack)
[![CI](https://img.shields.io/github/actions/workflow/status/kidskoding/anikonistack/ci.yml?branch=main&label=CI)](https://github.com/kidskoding/anikonistack/actions)
[![Nix](https://img.shields.io/badge/Nix-flakes-informational?logo=nixos&logoColor=white)](https://nixos.org)
[![skills](https://img.shields.io/badge/skills-12-blue)](./skills)
[![npm](https://img.shields.io/badge/npx-skills%20add-cb3837?logo=npm&logoColor=white)](https://www.npmjs.com/package/skills)
[![bun](https://img.shields.io/badge/bunx-skills%20add-f9f1e1?logo=bun&logoColor=black)](https://bun.sh)

**My agent stack: installable skills, and a fully reproducible Nix setup.**

This repo is two things that share one catalog:

1. **A skills pack**: custom agent skills you can drop into Cursor, Claude Code, Codex, and friends with `npx` / `bunx` (same flow as [mattpocock/skills](https://github.com/mattpocock/skills), [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills), [obra/superpowers](https://github.com/obra/superpowers)).
2. **A declarative agent stack**: a [home-manager](https://nix-community.github.io/home-manager/) module that pins those skills *plus* upstream bundles (Superpowers, Matt Pocock, Spartan, Caveman, …) and syncs them to every agent you enable. Same `flake.lock` → same `$HOME` agent config on any machine.

Most people only need path 1. Path 2 is for when you want the whole stack reproducible.

## Table of contents

- [Why this exists](#why-this-exists)
- [Quick start (skills only)](#quick-start-skills-only)
- [Available skills](#available-skills)
- [Suggested workflows](#suggested-workflows)
- [Full stack (Nix + home-manager)](#full-stack-nix--home-manager)
- [How the stack works](#how-the-stack-works)
- [Bundles](#bundles)
- [Agents](#agents)
- [Extending](#extending)
- [Updating](#updating)
- [Layout](#layout)
- [Verify](#verify)
- [License](#license)

## Why this exists

Coding agents are only as good as the skills and plugins you give them. Maintaining that by hand across Claude Code, Cursor, Codex, OpenCode, … means copying directories, fighting drift, and never quite knowing what’s installed where.

**anikonistack** declares the stack once:

| Layer | What you get |
|-------|----------------|
| **Custom skills** (`skills/`) | My day-to-day workflows (commits, PRs, issues, learning, writing) as proper [Agent Skills](https://agentskills.io/) |
| **Upstream bundles** (`catalog/`) | Pinned third-party packs (Superpowers, Matt Pocock, Spartan, …) via flake inputs |
| **Adapters** (`agents/`) | Per-agent home-manager wiring so each harness gets what it can actually load |

Install just the custom skills with the skills CLI, or flip on the Nix module and reproduce the whole environment.

## Quick start (skills only)

No Nix required. Works with Claude Code, Cursor, Codex, OpenCode, Windsurf, and [75+ agents](https://github.com/vercel-labs/skills/blob/main/docs/agents.md) via the [skills CLI](https://github.com/vercel-labs/skills).

```bash
# npm
npx skills add kidskoding/anikonistack

# bun
bunx skills add kidskoding/anikonistack
```

Pick skills interactively, or install everything:

```bash
npx skills add kidskoding/anikonistack -g -y -a '*' -s '*'
# or: bunx skills add kidskoding/anikonistack -g -y -a '*' -s '*'
```

| Command | What it does |
|---------|--------------|
| `npx skills add kidskoding/anikonistack -l` | List skills (no install) |
| `npx skills add kidskoding/anikonistack -s commit -g -y -a '*'` | One skill, all agents, global |
| `npx skills update` | Update installed skills |
| `npx skills use kidskoding/anikonistack@commit` | Use one skill without installing |

Swap `npx` for `bunx` anywhere. Browse on [skills.sh](https://skills.sh/kidskoding/anikonistack) once indexed.

<details>
<summary><strong>Install packs (examples)</strong></summary>

```bash
# Git / GitHub workflow
npx skills add kidskoding/anikonistack \
  -s commit modular-commits creating-pull-requests pr-review issue-fix \
  -g -y -a '*'

# Learning & writing
npx skills add kidskoding/anikonistack \
  -s eli5 coursera-notes course-quiz blog-post \
  -g -y -a '*'

# One skill into Cursor only
npx skills add kidskoding/anikonistack -s commit -a cursor -y
```

</details>

Skills activate when the task matches their description: say `"commit"`, `"open a PR"`, `"explain X eli5"`, and so on.

---

## Available skills

These live in [`skills/`](./skills/) and are also the Nix **`custom`** bundle. Each follows the [Agent Skills spec](https://agentskills.io/specification).

### Git & commits

#### [`commit`](./skills/commit/SKILL.md)

Conventional Commits for **one** logical change: named-file staging, imperative subjects, optional `fixes #N`.

**Use when:** `"commit"`, `"create a commit"`, `"save these changes"`, `"git commit"`.

**Requires:** `git` · Prefer [`modular-commits`](./skills/modular-commits/SKILL.md) when the tree has several unrelated changes.

#### [`modular-commits`](./skills/modular-commits/SKILL.md)

Split a messy working tree into **one commit per feature** (line-level, not file-level). Optional target count `k`; push by default.

**Use when:** `"modular commits"`, `"split these changes"`, `"split into 3 commits"`, `"commit this properly"`.

**Requires:** `git` · Single change → [`commit`](./skills/commit/SKILL.md).

### Pull requests

#### [`creating-pull-requests`](./skills/creating-pull-requests/SKILL.md)

Open a draft PR reviewers can decide on quickly: house rules, branch audit, gates, facts sheet, template.

**Use when:** `"open a PR"`, `"make a PR"`, `"write the PR description"`, `"is this ready to submit"`.

**Requires:** `git`, `gh` · Uses [`commit`](./skills/commit/SKILL.md) for messages.

#### [`pr-review`](./skills/pr-review/SKILL.md)

Review a GitHub PR: fetch diff/checks, quality + conventions, optional review comments.

**Use when:** `"review this PR"`, `"check PR #N"`, a PR URL, before merge.

**Requires:** `gh` · Fixing the underlying issue → [`issue-fix`](./skills/issue-fix/SKILL.md).

### Issues

#### [`issue-fix`](./skills/issue-fix/SKILL.md)

Triage and fix a GitHub issue end-to-end: fetch, plan, TDD, verify.

**Use when:** `"fix issue #N"`, `"work on this issue"`, `"resolve issue #N"`.

**Requires:** `git`, `gh`.

#### [`issue-comment`](./skills/issue-comment/SKILL.md)

Draft a **lore** (EpicGames/lore) issue comment: Problem → Reproduce → Suggested fix.

**Use when:** preparing a lore issue reply before a PR.

**Requires:** `gh`.

#### [`finding-contributor-issues`](./skills/finding-contributor-issues/SKILL.md)

Find a **safe** first issue: invite labels, maintainer signal, bounded scope, merge likelihood.

**Use when:** `"what should I contribute"`, `"find me a good first issue"`, `"what can I pick up in <repo>"`.

**Requires:** `gh`.

### Learning & writing

#### [`eli5`](./skills/eli5/SKILL.md)

Explain any concept, course module, or certification ELI5-style with real depth. Full rules in [`AGENTS.md`](./skills/eli5/AGENTS.md).

**Use when:** `/eli5 <topic>`, `"explain X eli5"`, `"what is X"`, `"how does X work"`, `"course databricks"`, `"explain module 1 of …"`.

#### [`coursera-notes`](./skills/coursera-notes/SKILL.md)

Turn any online course into study-guide notes (Markdown / Obsidian / Notion / Google Docs): not transcript dumps.

**Use when:** `"take notes from this course"`, `"course to notion/obsidian/markdown"`, `"note the videos"`.

**Requires:** Playwright MCP (+ Notion / Drive MCP for those destinations).

#### [`course-quiz`](./skills/course-quiz/SKILL.md)

Take a course quiz/exam in Playwright: discover the DOM, answer with you in the loop, report the score. Platform-agnostic.

**Use when:** `"do the exam/quiz in playwright"`, `"take the final assessment"`, `"get the certificate"`.

**Requires:** Playwright MCP; logged in on the course site. Refuses proctored / for-credit exams.

#### [`blog-post`](./skills/blog-post/SKILL.md)

Technical editor for developer posts: find the idea inside an experience, then draft. Also DEV.to import and news analysis.

**Use when:** `"write a blog post"`, critique a draft, internship/project → article, LinkedIn, DEV.to import.

Supporting files: `editor-workflow.md`, `style-guide.md`, `portfolio.md`, `news-analysis.md`.

### Project hygiene

#### [`update-claude-md`](./skills/update-claude-md/SKILL.md)

Diff ground truth vs `CLAUDE.md` and update so the agent contract stays accurate.

**Use when:** after structural changes, new commands/conventions, or end of a session that touched the codebase.

### Skill format

```
skills/<name>/
  SKILL.md          # required: YAML frontmatter + instructions
  …                 # optional references, scripts, assets
```

| Field | Required | Notes |
|-------|----------|-------|
| `name` | yes | Lowercase + hyphens; must match the directory |
| `description` | yes | What it does **and** when to use it (≤ 1024 chars) |
| `compatibility` | no | Env needs (`git`, `gh`, Playwright MCP, …) |
| `allowed-tools` | no | Space-separated allowlist (experimental) |

```bash
npx skills-ref validate skills/commit   # or bunx
for d in skills/*/; do npx skills-ref validate "$d"; done
```

---

## Suggested workflows

```text
messy tree ──► modular-commits ──► creating-pull-requests
one change ──► commit ───────────► creating-pull-requests

"good first issue?" ──► finding-contributor-issues ──► issue-fix
                                                    └─► issue-comment (lore) ──► creating-pull-requests

course open ──► coursera-notes ──► eli5 (hard bits) ──► course-quiz
experience ──► blog-post
```

---

## Full stack (Nix + home-manager)

Use this when you want **the entire agent environment** (custom skills *and* upstream bundles) as read-only symlinks into the Nix store, rebuilt from pinned inputs.

Requires [Nix](https://nixos.org/download) with flakes and [home-manager](https://nix-community.github.io/home-manager/). NixOS itself is **not** required (Linux, macOS, WSL all work).

### Minimal setup

```bash
# 1. install nix (flakes on)
# 2. starter home-manager flake
nix run home-manager -- init
```

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

Nothing is on by default. Pick bundles once; every enabled agent gets them unless it overrides:

```nix
anikonistack = {
  bundles = [ "custom" "mattpocock" "superpowers" "caveman" "spartan-core" ];
  skip    = [ "resolving-merge-conflicts" ];

  agents = {
    claude-code = {
      enable = true;
      statusline = true;                    # hooks/statusline.sh
    };
    codex.enable = true;
    cursor = {
      enable = true;
      bundles = [ "custom" "superpowers" ]; # cursor-only list
    };
  };
};
```

MCP servers stay in **your** config:

```nix
programs.mcp = {
  enable = true;
  servers = { /* … */ };
};
```

Every enabled agent picks them up. Secrets as `${VAR}`: never in this repo.

<details>
<summary><strong>Migrating from older anikonistack</strong></summary>

- `anikonistack.bundles.<name>.enable` → `anikonistack.bundles = [ … ]`
- Agents are opt-in → `anikonistack.agents.<agent>.enable = true`
- Renames: `own` → `custom`, `spartan` → `spartan-<pack>`
- MCP / Claude Code settings / packages are no longer set here: move them into your home-manager config

</details>

## How the stack works

```text
catalog/*.nix  ──►  lib/resolve.nix  ──►  agents/*.nix  ──►  ~/.<agent>/…
(bundles, pinned)   (depends + skips)     (one adapter)      (symlinks into store)
```

| Piece | Job |
|-------|-----|
| [`catalog/`](./catalog/) | Bundles with the same shape: `skills`, `plugin`, `native`, `commands`, `rules`, `subagents`, `scripts`, `context`, `depends` |
| [`catalog/spartan.nix`](./catalog/spartan.nix) | One bundle per [Spartan](https://github.com/c0x12c/ai-toolkit) pack |
| [`lib/resolve.nix`](./lib/resolve.nix) | Expands `depends`, native plugins vs flattened `skills/`, applies `skip` |
| [`module.nix`](./module.nix) | Options, assertions, `anikonistackLib.for "<agent>"` |
| [`agents/`](./agents/) | Per-agent adapters: write nothing unless enabled |
| [`flake.lock`](./flake.lock) | Every upstream pinned; `nix flake check` fails CI on missing paths |

**Eval-time guarantees**

- Unknown bundle or `skip` name → evaluation fails (with valid names)
- Same name from two bundles with different files → evaluation fails
- Bundle `depends` are pulled in automatically
- Native plugins install whole; skipping one of their skills only works when flattened (warning otherwise)

## Bundles

| Bundle | What | Contains | Depends on |
|--------|------|----------|------------|
| `custom` | **This repo’s skills** + CLAUDE.md sections | skills, context | |
| `superpowers` | [obra/superpowers](https://github.com/obra/superpowers) | plugin, skills | |
| `mattpocock` | [mattpocock/skills](https://github.com/mattpocock/skills) | skills | |
| `caveman` | Terse caveman-style output | plugin, skills | |
| `obsidian` | kepano’s Obsidian skills | skills | |
| `extras` | Assorted single skills | skills | |
| `firecrawl` | Firecrawl scrape / search | plugin, skills | |
| `frontend-design` | Anthropic frontend-design plugin | plugin, skills | |
| `last30days` | Research the last 30 days | plugin, skills | |
| `ponytail` | ponytail plugin | plugin, skills | |
| `duet` | claude-duet (Claude Code) | plugin | |
| `understand-anything` | Codebase knowledge graphs | plugin, skills | |
| `spartan-core` | Spartan core workflow | commands, rules, subagents, context | |
| `spartan-database` | DB patterns, Exposed ORM | skills, commands, rules, context | `spartan-core` |
| `spartan-shared-backend` | Shared backend concepts | rules | `spartan-core` |
| `spartan-backend-micronaut` | Kotlin + Micronaut | skills, commands, rules, subagents, context | `spartan-core`, `spartan-database`, `spartan-shared-backend` |
| `spartan-frontend-react` | React + Next.js | skills, commands, rules, context | `spartan-core` |
| `spartan-infrastructure` | Terraform + AWS | skills, commands, rules, subagents, context | `spartan-core` |
| `spartan-ops` | Deploy & ops | skills, commands, context | `spartan-core` |
| `spartan-product` | Product thinking | skills, commands, context | `spartan-core` |
| `spartan-research` | Startup research pipeline | skills, commands, subagents, context | `spartan-core`, `spartan-product` |
| `spartan-ux-design` | UX design workflow | skills, commands, rules, subagents, scripts, context | `spartan-core` |

`plugin` = agents with a native loader get the whole plugin; others get its `skills/`.

## Agents

| Agent | What the adapter installs |
|-------|---------------------------|
| `claude-code` | plugins, skills, commands, rules, subagents, scripts, context; optional `statusline` |
| `codex` | native plugins (caveman, ponytail, superpowers, last30days), skills |
| `opencode` | native plugins (ponytail, superpowers), skills |
| `antigravity` | skills |
| `cursor` | skills, `~/.cursor/mcp.json` |

Kinds an agent doesn’t support are simply omitted.

---

## Extending

### Add a custom skill (skills CLI + Nix)

1. Create `skills/<name>/SKILL.md`: `name` must match the directory.
2. Validate: `npx skills-ref validate skills/<name>`
3. It joins the `custom` bundle automatically and is installable via `npx` / `bunx skills add`.

### Add an agent adapter

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

Wire it in `agents/default.nix` and add `"myagent"` to `agentNames` in `module.nix`.

`anikonistackLib.for "<agent>"` returns `plugins`, `skills`, `commands`, `rules`, `subagents`, `scripts`, and `context`.

### Add upstream content

| What | Where |
|------|-------|
| Upstream skill | Flake input + line in a `catalog/*.nix` bundle |
| Plugin | Flake input + bundle in `catalog/plugins.nix`; optional `native.<agent>` |
| New group | `catalog/<name>.nix` + list it in `catalog/default.nix` |

Machine-specific bits (which agents, MCP servers, models, packages) live in **your** home-manager config, not here:

```nix
programs.claude-code.package = null;   # binary provided another way
```

---

## Updating

**Skills CLI**

```bash
npx skills update
# or: bunx skills update
```

**Nix stack**

```bash
nix flake update                             # here: commit flake.lock
nix flake lock --update-input anikonistack   # in your home-manager repo
home-manager switch --flake .
```

## Layout

```text
anikonistack/
├── flake.nix          # pins every upstream repo
├── flake.lock         # reproducible pins
├── module.nix         # home-manager options + assertions
├── catalog/           # bundles (custom, superpowers, spartan, …)
├── lib/               # resolve / pack / skill-dirs
├── agents/            # one adapter per agent
├── skills/            # custom skills: npx/bunx + custom bundle
├── hooks/             # statusline.sh
└── claude-md/         # CLAUDE.md sections (custom bundle)
```

## Verify

```bash
nix flake check                              # catalog + evaluation
npx skills add kidskoding/anikonistack -l    # discovery
npx skills add . -l                          # local checkout
for d in skills/*/; do npx skills-ref validate "$d"; done
```

## License

No license file is checked in yet: treat as all rights reserved unless one is added. Fork and remix for your own agent setup; contributions welcome once a license is chosen.
