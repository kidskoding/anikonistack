---
name: project-journal
description: Use when a PR or finished feature changes how the application works or adds a new tool or part of the system (for example the backend starts using a database, a new Cloudflare service, a new data model) in a project the user is learning from; when the user asks to "note this", "journal this", or "explain how this works"; or when the user wants to learn or rehearse the project ("teach me this project", "quiz me on X", "mock interview", "prep me for a demo", "practice explaining this"). Not for routine commits, config tweaks, refactors, or branch housekeeping.
---

# Project Journal

## Overview

The user is learning a project, often one where AI wrote much of the code, and the barrier is that nobody fully understands what was built. The vault exists so they **understand how the application works**: what problem it solves, and how it solves it technically. An AI should be able to teach the system from these notes, and the user should be able to read them in Obsidian on their own. Either way, the result is the same: they can explain the app's architecture in a demo, an interview, or to a teammate, and answer follow-up questions.

The vault has two kinds of notes:

- **`Home.md`, the architecture overview.** What problem the app solves, the main parts of the system, how they connect, and how one real request moves through them. Diagrams with explanations.
- **Term notes.** One note per key term: a tool (Cloudflare Workers, Durable Objects, PostgreSQL, Drizzle ORM) or a part of the app (`ReportRepository`, the shared API contract). Each one explains what the term is, what problem it solves in this app, how it works, and how it connects to other terms.

The skill has two jobs on the same vault: **writing** it (keeping the journal accurate as the project changes) and **teaching** from it (see Teach Mode), so the user can explain the project out loud. Teaching also improves the journal: any gap it finds gets written back.

The vault always describes the app **as it works now**. It is not a history of the project. There are no per-PR notes.

**The depth bar.** Every note goes in depth, and the bar for "deep enough" is: a smart newcomer who reads only this note (and follows its links), or is taught it by an AI, can explain the term and answer "why?" and "what happens if...?" follow-ups. Go as deep as that needs and no further. A note fails if it only names a term without making it understandable, and it also fails if the explanation is buried under detail the reader doesn't need.

## Never Committed, Always Excluded

The vault belongs to the person learning, not to the repo. **Never commit it and never add it to `.gitignore`**, because both change the shared repo. Exclude it locally with `.git/info/exclude`, which only affects this clone. Anyone who installs this skill builds their own vault from the repo on their own machine, so the skill works for any developer, on any project, without touching what the team shares.

## Disabled Projects

Skip the skill silently (no vault, no notes, no asking) in any project the user's own agent instructions (e.g. `CLAUDE.md`, `AGENTS.md`) list as disabled for project-journal, matched against the basename of the git repo root. The list lives in each user's instructions, not in this skill.

## When to Use

Update the vault when the work changes how the application works:

- A PR or finished feature adds a new part of the system, a new tool, or changes how the parts connect (for example: the Worker starts talking to PostgreSQL, a rate limiter is added, a new data model appears)
- A part of the system is removed or replaced, so the overview and term notes are now wrong
- The user says "note this", "journal this", "help me understand how this works"
- The user wants to study, be quizzed, or rehearse explaining the project (use Teach Mode)
- The project has no vault yet, or has an old-style vault (see Old-Style Vaults)

Skip it, without asking, for everything else: routine commits on an unfinished feature, config tweaks, dependency bumps, refactors and renames, tests-only or docs-only changes, typo and formatting fixes, and git housekeeping (stashes, rebases, branch cleanup). Small commits that build toward a feature are covered when that feature's PR is opened or merged.

## Vault Location

One vault per project. The real files live **outside the repo**, and a symlink makes them reachable from inside the project:

```
~/vaults/<project>/        # real vault; <project> = basename of the git repo root
├── Home.md                # architecture overview: problem, parts, diagrams, learning order, terms index
├── Practice.md            # Teach Mode results: strong and weak terms, questions missed
├── Cloudflare/            # area folder: term notes about one subject
│   ├── Cloudflare Workers.md
│   ├── Durable Objects.md
│   └── ...
├── Database/
├── Frontend/
├── <Area>/                # e.g. Backend and APIs, Tooling, Testing
└── <Project>.base         # optional Obsidian Bases index of terms by area
```

Areas are subjects a textbook chapter would use ("Cloudflare", "Database", "Frontend"), not names of packages or PRs. Create a new area folder only when a term doesn't fit an existing one. Note names must be unique across the vault, because wikilinks resolve by name.

```
<repo>/vault -> ~/vaults/<project>   # symlink, ignored locally only
```

If the vault doesn't exist, set it up from the repo root:

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
mkdir -p ~/vaults/"$project"
ln -sfn ~/vaults/"$project" vault
grep -qxF '/vault' .git/info/exclude || echo '/vault' >> .git/info/exclude
```

Use `.git/info/exclude` (local-only ignore list), **never** the shared `.gitignore`, so the repo itself is unchanged. Confirm with `git status` that `vault` doesn't appear. Obsidian treats any folder as a vault; the user opens it with "Open folder as vault".

`~/vaults` itself may be a symlink to somewhere else (for example, on WSL, a Windows folder so the Windows Obsidian app can open it). Always write through `~/vaults/...`, and never replace that symlink with a real directory.

If the vault path or the `vault` symlink would ever show up in `git status`, stop and fix the exclude before writing anything.

**REQUIRED SUB-SKILLS:** Load `obsidian-markdown` before writing notes (wikilinks, callouts, properties, mermaid). Load `obsidian-bases` before creating or editing the vault's `<Project>.base` file.

## Workflow

1. **Gather facts first.** Read the diff (`git diff`, `git log`), the PR body, the README, config files (e.g. `wrangler.jsonc`, `compose.yml`, `package.json`), and command output from this session. Never write from memory alone.
2. **Update `Home.md`** so the problem statement, the list of parts, every diagram, and the terms index match the app as it works now. If the vault is new, write it from the whole repo, not just this change.
3. **Create, update, or correct term notes.** List every term the change adds or affects. For each, search the vault by file name **and** by `aliases` before creating anything (`find ~/vaults/<project> -name '*.md'`, `grep -ril '<term>' ~/vaults/<project>`). If the note exists, work the new understanding into the place it fits. If something in a note is no longer true, rewrite or delete that part; don't append "update: ..." paragraphs. If a part of the app was removed, delete or rewrite its note and fix every link to it.
4. **Tell the user** in one or two sentences what changed in their understanding of the app, and which notes you created or updated.

## Old-Style Vaults

A vault with per-PR milestone notes, separate concept notes, or area "map" notes comes from an earlier version of this skill. Don't extend that shape. Tell the user the vault needs a one-time rebuild into the overview-plus-terms shape, and offer to do it: move the old vault to `~/vaults/<project>.bak-<YYYY-MM-DD>`, then write `Home.md` and term notes fresh from the repo, using the old notes only as a source of facts (problems hit, decisions and their reasons) that are still true.

## Teach Mode

A study session has one goal: by the end, the user can explain the project to a real audience and handle their questions. The session teaches first, then questions the user the way that audience would, then debriefs. The vault is the source of truth and the repo is the check. If the project has no vault or an old-style vault, say so and offer to build or rebuild it first.

### 1. Know the learner and pick the audience

If `Practice.md` doesn't record the user's background yet (for example new grad, frontend developer, backend developer, product manager), ask once and record it. Pitch every explanation to that background: define what they wouldn't know, skip what they would.

Then ask who the user is preparing for, unless they already said. The audience decides what gets taught and what gets asked:

- **Interviewer.** A software engineer or hiring manager. Cares about architecture, why each tool was chosen over the alternatives, tradeoffs, limits, failure cases, how it would scale, and what the user would change.
- **Demo customer.** Someone who might use or buy the app. Cares about the problem it solves for them, what they'd actually do in the app, whether it's reliable, whether their data is safe, and what happens when something goes wrong. Technical detail only as far as it answers those.

### 2. Teach what to learn

Read `Practice.md` first: start with terms marked weak and questions missed last time. Then teach in the `Home.md` Learning order, choosing what this audience needs:

- For an **interviewer**: the problem, the parts and how a request flows through them, then each key term (what it is, what problem it solves here, how it works, its limits), and the main tradeoffs.
- For a **demo customer**: the problem in their words, what the app does about it, and the main flow as they'd see it, with just enough of the system to answer "how does it know?" and "what if it breaks?".

Teach one piece at a time from its note, in plain words, then ask the user to say it back in a sentence or two before moving on. Correct anything wrong or missing and link the note.

### 3. Question the user in character

Tell the user the questioning round is starting, then play the audience. Stay in character for the whole round (about five to eight questions) and don't correct answers mid-round; a real interviewer or customer wouldn't. Ask one question at a time and wait for the answer. Build each next question on what the user just said, the way a real listener digs in.

Go from easy to hard. Open with "walk me through it" (a 30-second version, then two minutes). Then follow up on the user's own answer. Then ask the hard ones, every one grounded in a note or the repo:

- **Interviewer:** "Why X instead of Y?", "What happens if this part goes down?", "What breaks at 100 times the traffic?", "How would you debug a slow request?", "What would you change if you started over?"
- **Demo customer:** "Why would I use this instead of what I do now?", "What happens if I lose signal?", "Who can see my data?", "How do I know a report is accurate?", "What does it cost me to switch?"

The user can say "pause" at any point to step out of the round and ask for help.

### 4. Debrief and write it down

Step out of character. For each question, say what landed, what was missing or wrong, link the note that covers it, and give a stronger version of the answer in the user's own voice. End with the terms to revisit and the one-line "How I'd say it" for each.

Then update the journal:

- **`Practice.md`**: rewrite it to the current picture (not a log): terms the user explains well, terms that are weak, questions that tripped them up with a pointer to the note that answers each, and the date of the last session.
- **Notes**: if the user asked something the vault couldn't answer, find the answer in the repo or official docs and add it to the right note. If a note turned out to be wrong, fix it.

Rules for every session: one question at a time; never answer your own question; every explanation and judgment traces to a note or the repo, never memory.

## Note Shapes

Headings are not fixed. Name each section after what it is actually about ("Why a Worker can't keep a database connection", "Counting requests from every location at once"). "Sources" is the only generic heading allowed. Open every note with a plain paragraph saying what the thing is and why it matters, with no summary callout.

### `Home.md`: the architecture overview

```yaml
---
type: home
project: <project>
repo: <repo url>
---
```

Cover, in this order:

1. **The problem.** Who the app is for, what is broken or missing without it, and what the app does about it, in a few concrete paragraphs.
2. **The parts of the system.** Each main part (frontend, backend, database, hosting, shared packages), what it is responsible for, and which tools it uses, linking every term.
3. **Diagrams, each followed by a walkthrough** (see Diagrams): the system diagram, a sequence diagram of one real request end to end, and a data-model diagram if the app stores data.
4. **Why it is built this way.** The main architectural choices and what they trade off, in plain words, linking the term notes that explain each piece.
5. **What doesn't exist yet**, if the app is unfinished, so the reader knows which parts of the diagrams are planned.
6. **Learning order**: the terms in the order a newcomer should study them, following `learn-first` (parts the user touches first, then what they depend on).
7. **Terms index**, grouped by area, linking every term note with a few words each.

### Term notes

File: `<Area>/<Term>.md`.

```yaml
---
type: term
area: <Area>
tags: [term]
aliases: ["<short names, abbreviations, class names used in code>"]
official-docs: <url>
learn-first: ["[[<terms the reader must understand before this one>]]"]
uses: ["[[<terms this one calls, reads from, or depends on>]]"]
used-by: ["[[<terms that call or depend on this one>]]"]
---
```

`learn-first`, `uses`, and `used-by` make the links say **how** terms relate, not just that they do, and give Teach Mode a learning order. Keep them true in both directions: if A `uses` B, B is `used-by` A.

Every term note must cover:

- **What it is**, defined from scratch in plain words, then named: "...a program Cloudflare runs for each HTTP request, close to the user. Cloudflare calls this a **Worker**."
- **What problem it solves in this app.** This is the center of the note. What would go wrong without it, and why this tool or part was chosen for the job over the real alternatives.
- **How it works, step by step, in depth.** The mechanism behind its job here, its limits, and what happens in the failure cases. General ideas it relies on (connection pooling, rate limiting, migrations, dependency injection) are explained right here, in a paragraph, at the depth this term needs; they don't get their own notes.
- **Where it sits**: a small mermaid diagram of the term and what it talks to, followed by a short explanation.
- **How it connects to other terms**: wikilinks, and why each connection exists ("the Worker reaches the Durable Object through a [[Workers bindings|binding]], because...").
- **How it's used in this app**: real file paths and, if useful, a few real lines of code copied from the repo.
- **Problems hit**, if any are on record (PR bodies, commits, review comments, this session), with root cause and fix in a `> [!bug]` callout. Never invent them.
- **How I'd say it**: a heading with exactly this name, closing the note with two or three sentences the user could say out loud in an interview or demo to explain the term and why the app uses it.

A term note about a part of the app (e.g. a repository class or the API contract) follows the same shape; "official-docs" can be omitted.

### `Practice.md`

Written only by Teach Mode, and always rewritten to the current picture rather than appended to.

```yaml
---
type: practice
project: <project>
last-session: YYYY-MM-DD
learner-background: <e.g. new grad, backend developer, product manager>
audiences: [interviewer, demo-customer]
---
```

It lists terms the user explains well, terms that are weak (linked), and the questions that tripped them up, each with the audience that asked it and a link to the note that answers it.

### `<Project>.base` (optional)

An Obsidian Bases file with a view of term notes grouped by `area`. Create it once the vault has more than a handful of terms.

## Diagrams

Use lots of mermaid diagrams, and **always follow each diagram with text that walks through it**: what the boxes are, what moves along each arrow, and why. A diagram without an explanation is incomplete.

- **System diagram** (`flowchart`) in `Home.md`: every main part and tool, and how they connect. Mark planned or not-yet-built pieces with dotted arrows and say so in the text.
- **Sequence diagram** (`sequenceDiagram`) in `Home.md`: one real request, from the user's action to the response, through every part it actually touches. Add more sequence diagrams for other important flows (login, a write, a background job) when they exist.
- **Data-model diagram** (`erDiagram`) in `Home.md`, only if the app stores data: the real tables or collections and their relationships.
- **Where-it-sits diagram** in every term note: the term in the middle and the terms it talks to around it.
- Add other diagrams (state machines for a lifecycle, a flowchart for a decision the code makes) whenever they make an explanation easier to follow.

## Writing Rules

- **Accuracy over polish.** Every factual claim must trace to the repo, PR, command output, or official docs. If unsure, write "Not certain" rather than guessing.
- **No invented code.** Code is optional; if included, copy a few real lines from the repo with the file path. Never sketch API usage from memory.
- **Meet the depth bar, then stop.** Explain every moving part the reader needs to understand the term's job in this app. Leave out tool features the app doesn't use, long quotations from docs, and the history of how the code changed.
- **Plain language, explained thoroughly.** Assume a smart reader with no background. Say what the thing does directly, then name the technical term. Define each term the first time it appears.
- **Why before how.** Answer "what problem does this solve?" before "how does it work?"
- **No analogies or metaphors.** Describe what actually happens and why, in concrete terms.
- **Write like a person's own notes, not a filled-in form.** Connected paragraphs; bullets only for things a person would naturally list.
- **Bold, never italics.** Use `**bold**` for emphasis and for a technical term the first time it's named. Never use `*italics*` or `_italics_` anywhere in a note.
- **Link generously.** Every mention of another term is a `[[wikilink]]`, so the vault reads as a connected map of the system.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Note only names a term ("Durable Objects store state") | Explain what it is, what problem it solves here, and how it works until the depth bar is met |
| Explanation buried under unused features, doc quotes, or history | Cut everything that doesn't help someone understand this term's job in this app |
| Diagram with no text after it | Walk through the diagram: boxes, arrows, and why |
| Writing a note per PR or a project timeline | Update `Home.md` and the term notes so they describe the app as it works now |
| Appending "update: ..." paragraphs when something changed | Rewrite the part that is no longer true |
| Creating a duplicate note for a term that exists under an alias | Search file names and `aliases` first, then extend the existing note |
| Separate notes for general ideas like connection pooling | Explain the idea inside the term note that needs it |
| Defining a tool from its docs only | Define it by the job it does in **this** app |
| Organizing notes by PR, package, or project part | Organize term notes by subject in area folders |
| Italicizing a term or emphasis (`*Worker*`) | Bold it instead (`**Worker**`) |
| Links that don't say how terms relate | Fill `learn-first`, `uses`, `used-by`, kept true in both directions |
| Teach Mode lecturing without making the user explain | Ask the user to explain first, then correct from the notes |
| Teach Mode answering from memory when the vault lacks it | Check the repo or docs, answer, then write it into the vault |
| Committing the vault or adding it to `.gitignore` | Real files in `~/vaults/<project>/`; `<repo>/vault` is a symlink excluded via `.git/info/exclude` only |
| Inventing problems or decisions | Only record what the repo, PRs, or session show |
