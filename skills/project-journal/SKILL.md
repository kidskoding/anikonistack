---
name: project-journal
description: Use after a commit, finished task, drafted or merged PR, or other milestone in a project the user is learning from; when the user asks to "note this", "journal this", or "explain what we just did"; or when a project's Obsidian vault is missing earlier milestones and needs backfilling.
---

# Project Journal

## Overview

The user is learning by building. After each milestone, write Obsidian notes that let them **explain what was built, why it matters, and how the tools work** to anyone, from a non-technical friend to a senior engineer.

**Core principle:** notes are about understanding, not code. A note succeeds when the user can close it and explain the work out loud.

## When to Use

- After a commit, a finished task, or a PR (drafted, opened, or merged)
- The user says "note this", "journal this", "help me understand what we did"
- The vault is new or missing earlier milestones (see Backfilling)
- Not for trivial edits (typo fixes, formatting-only commits): skip them or fold them into the next milestone note

## Vault Location

One vault per project. The real files live **outside the repo**, and a symlink makes them reachable from inside the project:

```
~/vaults/<project>/        # real vault; <project> = basename of the git repo root
├── Home.md                # the project in plain English + milestone timeline
├── Milestones/            # one note per PR or milestone
├── Tools/                 # one evergreen note per tool, grows over time
├── Concepts/              # ideas that aren't tools (connection pooling, DI, ...)
└── <Project>.base         # Obsidian Bases overview: Milestones, Not merged yet, Tools, Concepts views

<repo>/vault -> ~/vaults/<project>   # symlink, ignored locally only
```

If the vault doesn't exist, set it up from the repo root:

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
mkdir -p ~/vaults/"$project"/{Milestones,Tools,Concepts}
ln -sfn ~/vaults/"$project" vault
grep -qxF '/vault' .git/info/exclude || echo '/vault' >> .git/info/exclude
```

Then create `Home.md`. Use `.git/info/exclude` (local-only ignore list), **never** the shared `.gitignore`, so the repo itself is unchanged. Confirm with `git status` that `vault` doesn't appear. Obsidian treats any folder as a vault; the user opens it with "Open folder as vault".

`~/vaults` itself may be a symlink. On WSL it points to a Windows folder (e.g. `/mnt/c/Users/<user>/Documents/vaults`) so the Windows Obsidian app can open the vaults; Windows can't follow Linux symlinks, so the real files must stay on the Windows side. Always write through `~/vaults/...`, and never replace that symlink with a real directory.

**REQUIRED SUB-SKILLS:** Load `obsidian-markdown` before writing notes (wikilinks, callouts, properties). Load `obsidian-bases` before creating or editing the vault's `<Project>.base` overview file.

## Workflow

1. **Gather facts first.** Read the diff (`git diff`, `git log`), the PR body, the project's roadmap/README, and command output from this session. Never write from memory alone.
2. **Check the timeline.** If `Home.md` is missing or earlier merged PRs have no milestone note, backfill them first (see Backfilling) so the vault tells the story in order.
3. **Update `Home.md`**: capture the project's purpose if it isn't there yet, and add the milestone to the timeline.
4. **Write the milestone note** (template below).
5. **Create or update a `Tools/` note** for every tool the milestone used. If the note exists, add a "How we used it" entry instead of rewriting it.
6. **Create `Concepts/` notes** only for ideas the milestone actually relied on.
7. **Tell the user** which notes you wrote and give the one-sentence summary.

## Backfilling

When starting a vault mid-project, rebuild the story from the beginning:

1. List merged PRs oldest first: `gh pr list --state merged --limit 100 --json number,title,mergedAt,url --jq 'sort_by(.mergedAt)'`. Also include pre-PR history (initial scaffold commits) as a "Milestone 0" note.
2. For each PR, read its body and diff (`gh pr view <n>`, `gh pr diff <n>`). Use the roadmap (e.g. `TODO.md`) for intent.
3. Write one milestone note per PR in chronological order, building tool notes as each tool first appears. Later notes link back to earlier ones.
4. Set `status: merged` and `backfilled: true` in properties. Mark "Problems we hit" as "Not recorded" unless the PR body, commits, or review comments show one. Don't invent struggles.

## Milestone Note Template

File: `Milestones/<NN> PR-<n> <short title>.md` (`NN` is a zero-padded sequence so the folder sorts in story order; use `00` for pre-PR scaffold)

```markdown
---
type: milestone
tags: [milestone]
aliases: ["PR #<n>"]
project: <project>
sequence: <NN>
date: YYYY-MM-DD
pr: <url or "not opened yet">
status: <local | draft | open | merged>
tools: ["[[Tool A]]", "[[Tool B]]"]
previous: "[[<previous milestone>]]"
---

# <Plain-English title: what it lets the product do>

> [!abstract] In one sentence
> <What we built and why, no jargon.>

## Why it matters
<The problem for the product or its users. What would break or be painful without it.>

## What we built
<A few connected paragraphs, in plain language, describing what now exists and what it does.>

## How it works
<Short Mermaid diagram of the moving parts, then a paragraph or two walking through it from start to finish.>

## Tools we used
- [[Tool A]]: <its job in this milestone, one line>

## Decisions and tradeoffs
<What we chose, what we didn't, and why. Include who decided if known (e.g. "boss asked for...").>

## Problems we hit
<What broke, the real root cause, how we fixed it. These are the best interview stories.>

## Explain it to...
> [!example]- A non-technical person
> <2-3 sentences in everyday words: what it does and why anyone should care.>

> [!example]- Your manager
> <2-3 sentences: value, risk, what it unlocks next.>

> [!example]- An engineer
> <2-3 sentences: the architecture and the interesting technical detail.>

## Check yourself
> [!question]- <Question 1>
> <Answer>

<3-5 questions that test *why*, not trivia.>

## What's next
<What this unlocks, linked to the next milestone if known.>

## Sources
<PR link, commit SHAs, docs actually consulted.>
```

## Tool Note Template

File: `Tools/<Tool Name>.md`

```markdown
---
type: tool
tags: [tool]
official-docs: <url>
first-used: "[[<milestone note>]]"
---

# <Tool Name>

> [!abstract] In one sentence
> <What it is, no jargon.>

## What problem it solves
## Why this project uses it (instead of alternatives)
## Key ideas to understand
## How we used it
- [[<milestone note>]]: <what we did with it>
## Gotchas we hit
```

## Writing Rules

- **Accuracy over polish.** Every factual claim must trace to the diff, PR, command output, or official docs. If unsure, write "Not certain" in the note rather than guessing.
- **No invented code.** Code is optional; if included, copy a few real lines from the repo with the file path. Never sketch API usage from memory.
- **Write flowing prose, not fragments.** Use full sentences that connect to each other with words like "because", "so", "which means", and "once that's in place". Each paragraph should read like someone explaining it out loud to a curious friend. Avoid strings of short, clipped sentences and avoid turning explanations into bullet lists.
- **Plain language, explained thoroughly.** Assume a smart reader with no background. Say what the thing is and what it does directly, then name the technical term: "...a small program that every other part of the app talks to when it needs data. Engineers call this a *service*." Define each term the first time it appears.
- **No analogies by default.** Explain the real thing clearly instead of comparing it to something else. Only use an analogy if a direct explanation genuinely isn't enough, and never as a required section.
- **Why before how.** Answer "why does this matter?" before "how does it work?"
- **Link generously.** Every tool and concept mention is a `[[wikilink]]`.
- **Keep it short.** A milestone note should be readable in under 5 minutes.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Choppy, clipped sentences or bullet-only explanations | Rewrite as connected paragraphs where each sentence leads into the next |
| Leaning on analogies instead of explaining | Describe what actually happens, in plain words |
| Restating the diff file by file | Describe the capability gained, not the files touched |
| Defining a tool from its docs only | Define it by the job it did in *this* project |
| Committing notes to the repo | Real files in `~/vaults/<project>/`; `<repo>/vault` is a symlink excluded via `.git/info/exclude` |
| Starting the vault at the current PR | Backfill earlier milestones first so the story is complete |
| Rewriting an existing tool note | Append to "How we used it" and fix only what's wrong |
| Inventing problems for backfilled PRs | Write "Not recorded" unless the PR history shows one |
