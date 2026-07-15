---
name: modular-commits
description: Use when the working tree holds several unrelated changes at once — multiple features, a fix, some reformatting — and they need to land as separate commits instead of one dump. Triggers include "modular commits", "split these changes", "split into 3 commits" or any named commit count, "commit this properly", "break this into commits", or asking to commit a tree where git status shows work from more than one thing.
usage: /modular-commits [k] [--push]
triggers:
  - "modular commits", "split into commits", "break this up into commits"
  - "split into K commits", "make that 4 commits", any named commit count
  - "commit and push" on a tree with several unrelated changes
skip_for: a tree with one logical change (use commit), creating PRs (use pr-review)
---

# Modular Commits

Split a messy working tree into one commit per feature. Grouping is by **feature,
not by file** — a single file's changes can land across several commits, line by
line.

Message format, types, scopes, and attribution: follow the `commit` skill. This
skill only covers the split.

## Core Principle

A commit is the smallest set of lines that expresses one intent. If a commit
message needs the word "and", it is two commits.

## Process

### Step 1: Back up before touching anything

```bash
mkdir -p /tmp/modular-commits
git diff HEAD > /tmp/modular-commits/pre-split.patch
git status --porcelain > /tmp/modular-commits/pre-split-status.txt
```

Recovery if a split goes wrong: `git reset HEAD~N && git apply /tmp/modular-commits/pre-split.patch`

### Step 2: See the whole picture

Run in parallel:
```bash
git status
git diff HEAD
git log --oneline -10
```

`git log` establishes this repo's scope naming. Untracked files do not appear in
`git diff` — read them separately.

### Step 3: Read the non-obvious changes

Do not group from filenames. Open the hunks whose intent is unclear and read
them. Bulk mechanical changes (a reformat, a rename sweep) hide real logic
changes inside them — those get their own commit, not a ride along with the
reformat.

### Step 4: Present the plan and WAIT

```
Proposed 3 commits:

1. feat(auth): add OAuth login
   src/auth.ts        (all)
   src/config.ts      L12-14

2. feat(cache): add response cache
   src/cache.ts       (all)
   src/config.ts      L20

3. fix(api): handle null payment response
   src/api.ts         L88-95

OK? (or: merge 1+2, reorder, move a line)
```

Wait for approval. Do not commit anything before it.

If a commit count was requested ("split into 4 commits"), hit it. If the changes
do not honestly divide that way, present the count that fits alongside the
requested one and let the user pick — never pad with empty commits or staple
unrelated features together to reach a number.

### Step 5: Commit each group

For files that belong entirely to one commit:
```bash
git add src/auth.ts
```

For a file split across commits, stage only that commit's lines via a filtered
patch:

```bash
git diff -- src/config.ts > /tmp/modular-commits/c1.patch
# edit c1.patch, then:
git apply --cached --recount /tmp/modular-commits/c1.patch
```

Filtering rules inside a hunk:

| Line | Belongs in this commit | Not in this commit |
|------|------------------------|--------------------|
| `+ added line` | keep as `+` | delete the line from the patch |
| `- removed line` | keep as `-` | change the leading `-` to a space (make it context) |
| ` context line` | keep | keep |

`--recount` makes git recompute the `@@` line counts, so hunk headers do not
need hand arithmetic. If `git apply` errors, the patch is wrong — fix it, never
reach for `--3way` or `--reject` to force it through.

Then commit with the `commit` skill's format:
```bash
git commit -m "$(cat <<'EOF'
feat(auth): add OAuth login

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

Repeat per group. After each commit, `git diff --stat` should shrink by exactly
that commit's lines.

### Step 6: Verify once, at the end

```bash
git status
git diff HEAD                # should be empty
git log --oneline -N
```

`git diff HEAD` empty proves nothing was dropped on the floor —
this is the check that matters. Then run the repo's test/build command **once**,
not per commit.

### Step 7: Push (only if asked)

```bash
git push
```

Report the SHAs and subjects.

## Quick Reference

| Situation | Do |
|-----------|-----|
| File belongs to one feature | `git add <file>` |
| File's lines span 2+ features | filtered patch + `git apply --cached --recount` |
| New untracked file | `git add` it into the commit that introduces its feature |
| Reformat touching everything | its own `style:`/`test:` commit, first — logic changes ride separately |
| Can't tell what a hunk is for | ask; do not guess it into a commit |
| A count was requested | hit it; if it doesn't divide honestly, offer both and let the user pick |

## Common Mistakes

**Grouping by file instead of feature.** The whole point is line-level. A
`config.ts` touched by three features is three commits' worth of lines.

**Letting a reformat swallow a logic change.** A 400-line parametrize sweep with
one real fix inside it is two commits, and the fix is the one people will bisect
for.

**Committing before the plan is approved.** The plan is the gate.

**Running tests after every commit.** Once at the end. The commits are a
narrative, not a CI matrix.

**`git add -A` "to save time".** It defeats the skill and stages unrelated files
and secrets.

## Red Flags — Stop

- About to write a commit subject containing "and"
- Staging a file you have not read the diff of
- `git apply` failed and you are reaching for `--reject` or `--3way`
- `git diff HEAD` is non-empty at the end and you cannot name every remaining line
- Pushing without being asked to push
