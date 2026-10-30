---
name: pr-create
description: Use when the user asks to create, open, prepare, or submit a GitHub pull request from the current branch, including a PR in a stacked branch workflow.
usage: /pr-create [optional base branch, issue number, or issue URL]
triggers:
  - '"create a PR", "open a pull request", "prepare the PR", "submit this branch"'
skip_for: reviewing an existing PR (use pr-review), committing uncommitted work (use commit or modular-commits)
---

# PR Create

Create a thorough **draft** PR from verified evidence. The human owns
publication: preview every GitHub mutation and wait for explicit approval.

## Inspect

Run read-only commands first:

```bash
git status --short --branch
git remote -v
git log --oneline --decorate -10
gh auth status
gh repo view --json defaultBranchRef,nameWithOwner
gh stack view --json
```

If the `gh stack` extension is not installed, or `view` exits `2` (not in a
stack) or `9` (stacked PRs unavailable), continue as an ordinary branch. Any
other failure from an installed extension is an error, not permission to guess.
For a stack, use the recorded parent as base. Otherwise use the explicit base,
existing PR base, or repository default branch, in that order.

Stop on detached HEAD, default/protected branches, ambiguous ancestry, or an
active rebase/merge. Never delete, stash, commit, or clean user files. Continue
with a dirty tree only after the user confirms those changes are excluded.

Check for an existing PR:

```bash
gh pr list --head "<head>" --state open --limit 1 \
  --json number,url,isDraft,baseRefName,headRefName,title,body
```

If one exists, offer to update its approved title or body; never create a
duplicate or change its draft status.

## Build the evidence

Read repository instructions and `.github` PR templates. Inspect the complete
range against the base:

```bash
git log --oneline "<base>..HEAD"
git diff --stat "<base>...HEAD"
git diff --check "<base>...HEAD"
git diff "<base>...HEAD"
```

Read linked issues. Run established checks when practical. Report exact results,
including pre-existing failures; never turn “not run” or “failed” into success.

## Compose

Draft a concise title and a body shaped to the change:

```markdown
## Summary
- What changed and why

## Implementation
- Important behavior, architecture, and data flow

## Testing
- `exact command` — exact result

## Review notes
- Recommended review order, known limitations, and follow-ups

## Stack
- Base PR/branch and dependent PRs (stacked branches only)
```

If a repository template exists, preserve every required section. Every claim
must come from the issue, commits, diff, or verification output.

## Mandatory approval gate

Show the user:

- head, base, and whether the branch is stacked;
- draft status;
- complete proposed title and body for every PR that will be created or edited;
- verification failures or omissions;
- every branch that a stack submission would push or create a PR for;
- exact push and PR commands.

Then stop. Only an explicit approval authorizes those exact commands. Approval
never includes requesting reviewers or marking the PR ready.

## Create

Push without force. If no upstream exists:

```bash
git push --set-upstream "<remote>" "<head>"
```

For an ordinary branch:

```bash
gh pr create --draft --base "<base>" --head "<head>" \
  --title "<approved title>" --body-file "<approved body file>"
```

For a stack, require `remote.pushDefault` or pass `--remote` explicitly:

```bash
gh stack submit --auto --remote "<remote>"
gh pr edit "<number-for-each-affected-branch>" \
  --title "<that branch's approved title>" \
  --body-file "<that branch's approved body file>"
```

`gh stack submit --auto` may affect multiple branches. If its affected set
changes, obtain new approval. Never bypass it with `gh pr create`, and do not
offer that bypass. If the approved subset cannot be isolated, explain the
conflict and do not mutate GitHub. Before submission, derive and preview a
separate title and body from each affected branch's own base diff. After
submission, update and verify every affected PR; never leave auto-generated
stack content as the final description.

Verify the result:

```bash
gh pr view "<number>" \
  --json number,url,isDraft,baseRefName,headRefName,title,body
```

The result must be draft, use the approved base/head/title/body, and contain no
reviewer request. Requests to mark an existing or new PR ready are outside this
skill: leave it draft and tell the user to review it first. On push or API
failure, leave local history untouched and report the failed command plus the
safest exact retry.

## Red flags

- Creating or editing a PR before showing the complete preview
- Guessing the base or a `gh stack` subcommand
- Using a commit message as the whole PR body
- Hiding failed or unrun checks
- Running `git clean`, force-pushing, requesting reviewers, or marking ready

Any red flag means stop and return to the approval gate.
