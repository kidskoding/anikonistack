---
name: sync-action-items
description: Use when the user asks to sync, refresh, or update ACTION_ITEMS.md (a local, git-excluded checklist) so its checkboxes, PR numbers, and PR stack match the current state on GitHub.
usage: /sync-action-items
triggers:
  - '"sync ACTION_ITEMS.md", "sync action items", "update action items", "refresh my action items"'
skip_for: creating PRs (use pr-create), reviewing PRs (use pr-review), editing tracked docs like TODO.md
---

# Sync ACTION_ITEMS.md

`ACTION_ITEMS.md` is a **personal, untracked** checklist at the repo root,
ignored through `.git/info/exclude`. GitHub is the source of truth. This skill
makes the file agree with GitHub without losing anything the user wrote.

## Hard rules

- Never `git add`, commit, or un-ignore `ACTION_ITEMS.md`. Never add it to `.gitignore`.
- The file has no git history safety net. **Back it up before writing**
  (`cp ACTION_ITEMS.md /tmp/ACTION_ITEMS.md.bak`).
- Never delete a user-written item or section. You can only:
  1. Tick or untick a checkbox.
  2. Fix a PR number, link, or branch name that disagrees with GitHub.
  3. Add a note or a new item or section for GitHub state that is not covered.
- Leave items untouched if GitHub cannot prove their state (e.g. "Plan the
  next stack"). Do not guess.
- Do not run git commands that change the working tree (checkout, rebase,
  reset). This skill only reads.

## 1. Preconditions

```bash
test -f ACTION_ITEMS.md || echo "missing"
git ls-files --error-unmatch ACTION_ITEMS.md 2>/dev/null && echo "TRACKED"
git check-ignore -v ACTION_ITEMS.md
git fetch --quiet --prune origin
```

- Missing: stop. Offer to recover it with
  `git log --all --format=%h -1 -- ACTION_ITEMS.md` + `git show <sha>^:ACTION_ITEMS.md`.
  The file deletes itself whenever a commit that removes it is checked out or
  rebased.
- Tracked: warn the user and stop. Do not fix it silently.
- Not ignored: offer to append `ACTION_ITEMS.md` to `$(git rev-parse --git-path info/exclude)`.

## 2. Gather GitHub state

```bash
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)

gh pr list --state all -L 50 --json number,title,state,isDraft,headRefName,baseRefName,reviewDecision,mergeable,mergedAt,url,statusCheckRollup \
  --jq '.[] | {number,title,state,isDraft,head:.headRefName,base:.baseRefName,reviewDecision,mergeable,mergedAt,url,
               checks:([.statusCheckRollup[]|(.conclusion // .state)]|group_by(.)|map({(.[0]):length})|add)}'

gh api graphql -f query='query($o:String!,$r:String!){repository(owner:$o,name:$r){pullRequests(states:[OPEN,MERGED],last:50){nodes{number reviewThreads(first:100){nodes{isResolved}}}}}}' \
  -f o="${REPO%/*}" -f r="${REPO#*/}" \
  --jq '.data.repository.pullRequests.nodes[] | "\(.number) unresolved=\([.reviewThreads.nodes[]|select(.isResolved|not)]|length)"'
```

For stack and rebase items, test ancestry against remote refs:

```bash
git merge-base --is-ancestor origin/<base> origin/<branch> && echo "rebased on <base>"
git ls-remote --heads origin <branch>   # does the branch exist on GitHub?
```

## 3. Map GitHub state to checkboxes

Find each PR by its **head branch name** first, then by number. PR numbers in
the file are often wrong (e.g. a guessed "PR #10" that was actually opened as #11).

| Item wording (approximate)                  | Checked when                                                                                    |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Receive required code review approval       | `reviewDecision == APPROVED` or PR merged                                                       |
| Address code review feedback                | merged, or (`reviewDecision != CHANGES_REQUESTED` **and** 0 unresolved threads **and** ≥1 review) |
| Confirm all checks pass                     | every check is SUCCESS / SKIPPED / NEUTRAL and there is at least one check                      |
| Merge PR #N into `X`                        | `state == MERGED`. Also fix `X` if `baseRefName` differs                                        |
| Rebase `A` onto `B` (after …)               | `origin/B` is an ancestor of `origin/A`, or A's PR is merged                                    |
| Complete `A` and have it code reviewed      | PR for `A` exists, is not a draft, and is APPROVED or merged                                     |
| Have the stack … reviewed and merged        | every PR in that stack is merged                                                                |

Handle the edge cases this way:

- Item checked, but GitHub says otherwise (e.g. new CHANGES_REQUESTED, a failing
  check): **untick it** and explain why in the summary.
- A branch mentioned with no PR: keep it unchecked and add ` (no PR yet)` once
  if it is not already there.
- A PR number with no link: turn it into `[PR #N](url)`.
- A section title that lists PR numbers (e.g. `(PR #9, #10, #11)`): rewrite the
  numbers to match the real PRs.

## 4. Add what's missing

For each **open** PR not mentioned anywhere in the file, append a section that
follows the existing style:

```markdown
## PR #N — <title>

- [ ] Receive required code review approval
- [ ] Address any code review feedback
- [ ] Confirm all checks pass
- [ ] Merge [PR #N](<url>) into `<base>`
```

Then tick its boxes using the rules in step 3. Ignore merged or closed PRs that
were never in the file.

If a PR's base is another PR's head branch, it is part of a stack. Put it
next to that stack's section, not at the end.

## 5. Write, diff, report

1. Back up the file, then make the edits in place. Keep headings, order,
   wording, and the user's typos.
2. Show `diff -u /tmp/ACTION_ITEMS.md.bak ACTION_ITEMS.md`.
3. Write a short summary: items ticked, items unticked (with the reason), PR
   numbers fixed, sections added. Then list what still blocks progress, e.g.
   "PR #9: changes requested", "PR #11: 12 unresolved threads, review required".
4. Delete the backup only after the user has seen the diff.
