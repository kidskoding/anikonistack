# anikonistack

[![skills.sh](https://skills.sh/b/kidskoding/anikonistack)](https://skills.sh/kidskoding/anikonistack)

**One catalog. Every agent.** Declare skills, plugins, and MCP once — ship them to Claude Code, Codex, OpenCode, Cursor, and Antigravity.

| Path | Who it's for | Install |
|------|--------------|---------|
| **Skills only** | Any machine with npm or bun — no Nix | `npx` / `bunx skills add` (~30s) |
| **Full stack** | Declarative, reproducible agent configs | Nix + home-manager module |

---

## Install the skills

Works with Claude Code, Cursor, Codex, OpenCode, Windsurf, and [75+ agents](https://github.com/vercel-labs/skills/blob/main/docs/agents.md) via the [skills CLI](https://github.com/vercel-labs/skills).

```bash
# npm
npx skills add kidskoding/anikonistack

# bun
bunx skills add kidskoding/anikonistack
```

Interactive by default. Install everything non-interactively:

```bash
npx skills add kidskoding/anikonistack -g -y -a '*' -s '*'
# or: bunx skills add kidskoding/anikonistack -g -y -a '*' -s '*'
```

| Command | What it does |
|---------|--------------|
| `npx skills add kidskoding/anikonistack -l` | List skills in the repo (no install) |
| `npx skills add kidskoding/anikonistack -s commit -g -y -a '*'` | One skill, all agents, global |
| `npx skills update` | Update installed skills |
| `npx skills use kidskoding/anikonistack@commit` | Use one skill without installing |

Swap `npx` for `bunx` anywhere above. Browse on [skills.sh](https://skills.sh/kidskoding/anikonistack).

---

## Custom skills catalog

These are the skills in [`skills/`](./skills/) — the Nix `custom` bundle. Each has a valid [`SKILL.md`](https://agentskills.io/specification) (checked with `skills-ref`). Install one with `-s <name>`, or all with `-s '*'`.

### Quick index

| Category | Skills |
|----------|--------|
| **Git & commits** | [`commit`](./skills/commit/SKILL.md) · [`modular-commits`](./skills/modular-commits/SKILL.md) |
| **Pull requests** | [`creating-pull-requests`](./skills/creating-pull-requests/SKILL.md) · [`pr-review`](./skills/pr-review/SKILL.md) |
| **Issues** | [`issue-fix`](./skills/issue-fix/SKILL.md) · [`issue-comment`](./skills/issue-comment/SKILL.md) · [`finding-contributor-issues`](./skills/finding-contributor-issues/SKILL.md) |
| **Learning** | [`eli5`](./skills/eli5/SKILL.md) · [`coursera-notes`](./skills/coursera-notes/SKILL.md) · [`course-quiz`](./skills/course-quiz/SKILL.md) |
| **Writing** | [`blog-post`](./skills/blog-post/SKILL.md) |
| **Hygiene** | [`update-claude-md`](./skills/update-claude-md/SKILL.md) |

### Full reference

| Skill | What it does | Example triggers | Requires | Related / instead of |
|-------|--------------|------------------|----------|----------------------|
| [`commit`](./skills/commit/SKILL.md) | Conventional Commits for **one** logical change — stage named files, imperative subject, optional `fixes #N`, co-author line | `"commit"`, `"create a commit"`, `"save these changes"`, `"git commit"` | `git` | Several unrelated changes → [`modular-commits`](./skills/modular-commits/SKILL.md); opening a PR → [`creating-pull-requests`](./skills/creating-pull-requests/SKILL.md) |
| [`modular-commits`](./skills/modular-commits/SKILL.md) | Split a messy working tree into **one commit per feature** (not per file); optional target count `k`; push by default | `"modular commits"`, `"split these changes"`, `"split into 3 commits"`, `"commit this properly"`, `"break this into commits"` | `git` | Single logical change → [`commit`](./skills/commit/SKILL.md); then open PR → [`creating-pull-requests`](./skills/creating-pull-requests/SKILL.md) |
| [`creating-pull-requests`](./skills/creating-pull-requests/SKILL.md) | Open a draft PR reviewers can decide on fast — house rules, branch audit, gates, facts sheet, template fill | `"open a PR"`, `"make a PR"`, `"write the PR description"`, `"is this ready to submit"` | `git`, `gh` | Uses [`commit`](./skills/commit/SKILL.md) for messages; reviewing someone else's PR → [`pr-review`](./skills/pr-review/SKILL.md) |
| [`pr-review`](./skills/pr-review/SKILL.md) | Review a GitHub PR — fetch diff/checks, quality + conventions, optional review comments | `"review this PR"`, `"check PR #N"`, `"review pull request"`, a PR URL, before merge | `gh` | Fixing the issue behind the PR → [`issue-fix`](./skills/issue-fix/SKILL.md); local review with no PR → skip |
| [`issue-fix`](./skills/issue-fix/SKILL.md) | Fix a GitHub issue end-to-end — triage, branch, plan, TDD implement, verify | `"fix issue #N"`, `"work on this issue"`, `"resolve issue #N"`, any issue number | `git`, `gh` | Obvious one-line bug → just fix; reviewing a PR → [`pr-review`](./skills/pr-review/SKILL.md) |
| [`issue-comment`](./skills/issue-comment/SKILL.md) | Draft a **lore** (EpicGames/lore) issue comment: Problem → Reproduce → Suggested fix | Preparing a lore issue reply before a PR; `"structure this issue comment"` | `gh` | Opening the PR after → [`creating-pull-requests`](./skills/creating-pull-requests/SKILL.md) |
| [`finding-contributor-issues`](./skills/finding-contributor-issues/SKILL.md) | Find a **safe** first issue — invite labels, maintainer signal, bounded scope, merge likelihood | `"what should I contribute"`, `"find me a good first issue"`, `"what can I pick up in <repo>"`, “is this issue safe?” | `gh` | After picking → [`issue-fix`](./skills/issue-fix/SKILL.md) or [`issue-comment`](./skills/issue-comment/SKILL.md) |
| [`eli5`](./skills/eli5/SKILL.md) | Explain any concept, course module, or cert ELI5-style with real depth; optional save to disk / Word / Notion. Full rules in [`AGENTS.md`](./skills/eli5/AGENTS.md) | `/eli5 <topic>`, `"explain X eli5"`, `"what is X"`, `"how does X work"`, `"course databricks"`, `"explain module 1 of …"` | — (web fetch optional) | Course transcript notes → [`coursera-notes`](./skills/coursera-notes/SKILL.md); graded quiz → [`course-quiz`](./skills/course-quiz/SKILL.md) |
| [`coursera-notes`](./skills/coursera-notes/SKILL.md) | Turn **any** online course into study-guide notes (not transcript dumps) in Markdown/Obsidian, Notion, or Google Docs; mirrors the real course tree | `"take notes from this course"`, `"course to notion/obsidian/markdown"`, `"note the videos"`, point at an open course | Playwright MCP (+ Notion / Drive MCP for those destinations) | Explaining a topic → [`eli5`](./skills/eli5/SKILL.md); taking the exam → [`course-quiz`](./skills/course-quiz/SKILL.md) |
| [`course-quiz`](./skills/course-quiz/SKILL.md) | Take a course quiz/exam in Playwright — discover DOM, answer with user in the loop, submit, report score. Coursera, edX, Udemy, Skilljar, Cloud Skills Boost, LMS, … | `"do the exam/quiz in playwright"`, `"take the final assessment"`, `"answer the quiz for me"`, `"get the certificate"` | Playwright MCP; logged in on the course site | Notes first → [`coursera-notes`](./skills/coursera-notes/SKILL.md); refuses proctored / for-credit exams |
| [`blog-post`](./skills/blog-post/SKILL.md) | Technical editor for developer posts — extract idea from experience, thesis, narrative, draft, edit. Also DEV.to import + news analysis. Supporting: `editor-workflow.md`, `style-guide.md`, `portfolio.md`, `news-analysis.md` | `"write a blog post"`, `"help me draft this"`, critique a draft, internship/project → article, LinkedIn post, DEV.to import, news analysis | — | Explaining a concept only → [`eli5`](./skills/eli5/SKILL.md) |
| [`update-claude-md`](./skills/update-claude-md/SKILL.md) | Diff ground truth vs `CLAUDE.md` and update so the agent contract stays accurate | After adding files / commands / conventions; end of a session that touched the codebase; `"update CLAUDE.md"` | — | — |

### Suggested flows

```text
messy tree ──► modular-commits ──► creating-pull-requests
one change ──► commit ───────────► creating-pull-requests

"good first issue?" ──► finding-contributor-issues ──► issue-fix
                                                    └─► issue-comment (lore) ──► creating-pull-requests

course open ──► coursera-notes ──► eli5 (hard bits) ──► course-quiz
experience ──► blog-post
```

### Install examples (custom skills)

```bash
# everything in this catalog
npx skills add kidskoding/anikonistack -s '*' -g -y -a '*'

# git workflow pack
npx skills add kidskoding/anikonistack \
  -s commit modular-commits creating-pull-requests pr-review issue-fix \
  -g -y -a '*'

# learning pack
npx skills add kidskoding/anikonistack \
  -s eli5 coursera-notes course-quiz blog-post \
  -g -y -a '*'

# one skill into Cursor only
npx skills add kidskoding/anikonistack -s commit -a cursor -y
```

### Skill format

Skills follow the [Agent Skills specification](https://agentskills.io/specification):

```
skills/<name>/
  SKILL.md          # required — YAML frontmatter + instructions
  …                 # optional references, scripts, assets
```

Frontmatter is limited to spec fields:

| Field | Required | Notes |
|-------|----------|-------|
| `name` | yes | Lowercase, hyphens; must match the directory name |
| `description` | yes | What it does **and** when to use it (≤ 1024 chars) |
| `compatibility` | no | Env requirements (`git`, `gh`, Playwright MCP, …) |
| `allowed-tools` | no | Space-separated tool allowlist (experimental) |
| `license` / `metadata` | no | Optional |

Validate locally:

```bash
npx skills-ref validate skills/commit   # or: bunx skills-ref …
for d in skills/*/; do npx skills-ref validate "$d"; done
```

---

## Install the full stack (Nix)

The home-manager module makes **every agent config under `$HOME` a read-only symlink into the Nix store**, rebuilt from pinned inputs. Same lock → same result on any machine.

Requires [Nix](https://nixos.org/download) with flakes and [home-manager](https://nix-community.github.io/home-manager/). NixOS itself is not required (Linux, macOS, and WSL all work).

```bash
# 1. install nix (flakes on)
# 2. get a starter home-manager flake
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

Nothing is on by default. Pick bundles once; every enabled agent gets them unless it sets its own list:

```nix
anikonistack = {
  bundles = [ "custom" "mattpocock" "superpowers" "caveman" "spartan-core" ];
  skip    = [ "resolving-merge-conflicts" ];   # single skills / commands / rules / subagents

  agents = {
    claude-code = {
      enable = true;
      statusline = true;                       # hooks/statusline.sh
    };
    codex.enable = true;
    cursor = {
      enable = true;
      bundles = [ "custom" "superpowers" ];    # replaces the global list for cursor only
    };
  };
};
```

MCP servers stay in your config — set `programs.mcp = { enable = true; servers = { … }; };` and every enabled agent picks them up.

### How it works

```
catalog/*.nix ─► lib/resolve.nix ─► agents/*.nix, one per agent ─► ~/.<agent>/…
(every bundle)   (your bundles +     claude-code.nix, codex.nix, …
                  skips, per agent)
```

| Piece | Job |
|-------|-----|
| `catalog/` | Every bundle, pinned via flake inputs — same optional fields: `skills`, `plugin`, `native`, `commands`, `rules`, `subagents`, `scripts`, `context`, `depends` |
| `catalog/spartan.nix` | One bundle per [Spartan](https://github.com/c0x12c/ai-toolkit) pack, from `packs/*.yaml` via `lib/pack.nix` |
| `lib/resolve.nix` | Expands `depends`, loads plugins natively when available, flattens `skills/` otherwise, applies `skip` |
| `module.nix` | Options, assertions, `anikonistackLib.for "<agent>"` for adapters |
| `agents/` | One adapter per agent — writes nothing unless that agent is enabled |
| `flake.lock` | Every upstream repo pinned; `nix flake check` fails CI if a path goes missing |

Eval-time guarantees:

- Misspelled bundle or unknown `skip` → evaluation fails with valid names
- Two bundles defining the same name with different files → evaluation fails
- Choosing a bundle pulls in its `depends`
- A native-loaded plugin is installed whole; skipping one of its skills only works for agents that flatten it (warning otherwise)

### Bundles

| Bundle | What | Contains | Depends on |
|--------|------|----------|------------|
| `caveman` | Terse caveman-style output | plugin, skills | |
| `custom` | This repo's own skills and CLAUDE.md sections | skills, context | |
| `duet` | claude-duet commands (Claude Code only) | plugin | |
| `extras` | Single skills from assorted repos | skills | |
| `firecrawl` | Firecrawl web scraping and search | plugin, skills | |
| `frontend-design` | Anthropic's frontend-design plugin | plugin, skills | |
| `last30days` | Research what happened in the last 30 days | plugin, skills | |
| `mattpocock` | Matt Pocock's engineering and productivity skills | skills | |
| `obsidian` | kepano's Obsidian skills | skills | |
| `ponytail` | ponytail plugin | plugin, skills | |
| `spartan-backend-micronaut` | Kotlin + Micronaut backend | skills, commands, rules, subagents, context | `spartan-core`, `spartan-database`, `spartan-shared-backend` |
| `spartan-core` | Core workflow | commands, rules, subagents, context | |
| `spartan-database` | Database patterns, migrations, Exposed ORM | skills, commands, rules, context | `spartan-core` |
| `spartan-frontend-react` | React + Next.js frontend | skills, commands, rules, context | `spartan-core` |
| `spartan-infrastructure` | Terraform + AWS infrastructure | skills, commands, rules, subagents, context | `spartan-core` |
| `spartan-ops` | Deploy & infrastructure | skills, commands, context | `spartan-core` |
| `spartan-product` | Product thinking before building | skills, commands, context | `spartan-core` |
| `spartan-research` | Startup research pipeline | skills, commands, subagents, context | `spartan-core`, `spartan-product` |
| `spartan-shared-backend` | Shared backend architecture concepts | rules | `spartan-core` |
| `spartan-ux-design` | UX design workflow | skills, commands, rules, subagents, scripts, context | `spartan-core` |
| `superpowers` | obra's superpowers workflow skills | plugin, skills | |
| `understand-anything` | Codebase knowledge graphs | plugin, skills | |

`plugin` means agents with a native loader for it load the whole plugin; the others get its `skills/`.

### Agents

| Agent | Takes |
|-------|-------|
| `claude-code` | plugins, skills, commands, rules, subagents, scripts (`~/.claude/scripts`), context; optional `statusline` |
| `codex` | native plugins (caveman, ponytail, superpowers, last30days), skills |
| `opencode` | native plugins (ponytail, superpowers), skills |
| `antigravity` | skills |
| `cursor` | skills, `~/.cursor/mcp.json` |

Kinds an agent does not take are left out for that agent.

---

## Extending the stack

### Add a skill (skills CLI + Nix)

1. Create `skills/<name>/SKILL.md` with valid frontmatter (`name` must match the directory).
2. Validate: `npx skills-ref validate skills/<name>` (or `bunx`)
3. It is automatically part of the `custom` bundle and installable via `npx` / `bunx skills add`.

### Add an agent

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

| Field | What |
|-------|------|
| `plugins` | `{ <bundle> = <path>; }` — plugins this agent loads natively |
| `skills` | `{ <name> = <path>; }` — bundle skills plus flattened skills of other plugins |
| `commands`, `rules`, `subagents`, `scripts` | `{ <name> = <path>; }` |
| `context` | List of CLAUDE.md sections, in key order |

Agent-specific options go in the adapter (e.g. `statusline` in `agents/claude-code.nix`).

### Add other content

| What | Where |
|------|-------|
| Upstream skill | Flake input + one line in a `catalog/*.nix` bundle |
| Plugin | Flake input + one bundle in `catalog/plugins.nix`; add `native.<agent>` if it ships a loader |
| New group | New `catalog/<name>.nix`, listed in `catalog/default.nix` |

Secrets never go in the repo. Reference them as `${VAR}` in `programs.mcp.servers` and export the variable before launching.

### Machine-specific config

Lives in **your** home-manager config, not here: which agents and bundles, MCP servers, agent settings (model, permissions), which package provides a binary.

```nix
programs.claude-code.package = null;   # binary already installed another way
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
nix flake update                             # in this repo, commit flake.lock
nix flake lock --update-input anikonistack   # in your home-manager repo
home-manager switch --flake .
```

### Migrating from older anikonistack

- `anikonistack.bundles.<name>.enable` is gone → use `anikonistack.bundles = [ … ]`
- Agents are opt-in → `anikonistack.agents.<agent>.enable = true`
- Bundle renames: `own` → `custom`, `spartan` → `spartan-<pack>`
- MCP servers / Claude Code settings / packages are no longer set here — move them into your own config

---

## Layout

```
anikonistack/
├── flake.nix          # pins every upstream repo
├── module.nix         # options, assertions, module argument
├── catalog/           # every bundle, one file per group
├── lib/               # pack.nix, resolve.nix, skill-dirs.nix
├── agents/            # one adapter per agent
├── skills/            # own skills — npx/bunx installable (bundle `custom`)
├── hooks/             # statusline.sh
└── claude-md/         # own CLAUDE.md sections (bundle `custom`)
```

## Verify

```bash
# Nix catalog + evaluation
nix flake check

# Skills discovery (skills CLI)
npx skills add kidskoding/anikonistack -l
# or locally:
npx skills add . -l

# Spec compliance (every skill)
for d in skills/*/; do npx skills-ref validate "$d"; done
```

## License

See the repository for details. Skills and the Nix module are meant to be forked, remixed, and wired into your own agent setup.
