---
name: finding-contributor-issues
description: "Use when the user wants an issue to work on in an open-source repo, asks 'what should I contribute', 'find me a good first issue', 'what can I pick up in <repo>', or wants to know whether a specific issue is safe to start on."
allowed_tools:
  - Read
  - Bash
  - Grep
  - Glob
---

# Finding Contributor Issues

## Overview

A good issue for an outside contributor has four properties, checked in this order: nobody else is on it, a maintainer has already said yes to the direction, the fix is bounded to code you can read in an hour, and the repo will actually merge it. Most "good first issue" labels fail the first check.

**Core principle:** an issue's label is a claim. The comment thread and the PR list are the evidence.

## Step 1: Read the rules once

1. `CONTRIBUTING.md`: which labels invite contribution, which forbid it, whether claiming an issue is required, AI policy link.
2. `gh label list --limit 100 --json name,description`: the repo's actual invite labels (`help wanted`, `good first issue`, `E-easy`, `contributions welcome`) and block labels (`needs-design`, `needs-decision`, `wontfix`, `needs-mre`, `blocked`).

Record both lists. They drive every query below.

## Step 2: Pull candidates, in this order, until 8 survive the discard rules

```bash
# Invite labels first
gh issue list --label "<invite label>" --state open --limit 50 \
  --json number,title,labels,comments,assignees,updatedAt

# Then the second-tier label CONTRIBUTING names (often `bug`), filtered hard
gh issue list --label "<second-tier label>" --state open --limit 100 \
  --search "no:assignee comments:<=6 -label:<block label> sort:updated-desc" \
  --json number,title,labels,comments,assignees,updatedAt

# Then maintainer-filed issues in bounded areas (error messages, docs, CLI hints)
gh issue list --state open --limit 100 --search "author:<maintainer> -label:<block label>" \
  --json number,title,labels,comments,assignees,updatedAt
```

Discard on sight: any assignee, any block label, more than 15 comments, updated within the last 3 days by someone other than the reporter.

The 8 survivors are the vetting list. Step 3 runs on those 8 and no others. A ninth candidate means one of the 8 was discarded in Step 3 for an open PR.

## Step 3: Vet each of the 8 with exactly three calls

```bash
gh issue view <N> --json title,body,labels,assignees,comments \
  --jq '{title, labels: [.labels[].name], n: (.comments|length), last3: [.comments[-3:][] | {a: .author.login, b: .body[0:300]}]}'
gh pr list --state all --search "<N> in:title,body" --limit 10 --json number,state,isDraft,updatedAt,author,reviewDecision
gh search issues --repo <owner/repo> --state open "<3 distinctive words from title>" --limit 5   # duplicates
```

Score:

| Signal                                                                                | Points                     |
| ------------------------------------------------------------------------------------- | -------------------------- |
| Maintainer comment agreeing on the fix direction                                      | +3                         |
| No PR ever opened                                                                     | +2                         |
| PR exists, closed, not merged, closed for process reasons (AI policy, author gave up) | +1, note it as prior art   |
| PR exists, open, updated in last 90 days                                              | reject                     |
| PR exists, open, stale over 90 days, no review                                        | 0, must ask on issue first |
| Regression test or repro already in repo                                              | +2                         |
| Fix touches one crate or package                                                      | +1                         |
| Issue body has a copy-paste repro                                                     | +1                         |

Keep the top 3 by score.

## Step 4: Locate the code, one grep per pick

For each pick, one search to name the file and function the fix lives in. Confirm it exists. Stop there. Do not design the fix.

## Step 5: Output

```
RULES         claim required: yes/no | AI policy: <one line or "none"> | block labels: <list>

PICK 1  #<N>  <title>
  score <n>   labels <...>
  why safe    <maintainer quote or "no maintainer signal", PR history in one clause>
  where       <path:line, function>
  size        <hours estimate, one clause on why>
  prior art   <PR numbers or "none">

PICK 2 ...
PICK 3 ...

START WITH    #<N> because <one sentence>
SKIPPED       #<N> <reason>, #<N> <reason>   (one line, not a paragraph each)
NEXT STEP     claim needed: yes/no | comment must state: <who to address>, <the fix direction in one clause>, <ask whether anyone is on it>
```

## Gotchas

- **Every `help wanted` issue you can find in one query is already taken.** Baseline vetting on uv found zero open `good first issue` and every bounded `help wanted` issue had 1 to 3 attached PRs. The PR search in Step 3 is the gate. Skip it and you recommend duplicated work.
- **Thirty issue views is a failed search.** Baseline spent 27 tool calls and 174k tokens for 3 picks. Step 2's discard rules and Step 3's three-call limit exist because the results were the same with a tenth of the reads.
- **A PR closed for AI-policy reasons is a green light, not a warning.** The maintainer liked the patch. A human-authored redo of the same idea is welcome. Report it as prior art.
- **Maintainer-filed issues with zero comments beat labeled issues with ten.** The maintainer already wants it and nobody is arguing about the design.
- **Stale open PR still blocks.** Ask on the issue whether the PR is abandoned before starting. Never open a competing PR silently.
- **Do not comment, assign, or react on anyone's behalf.** Output what the claim comment must contain, never its text. Repos with an AI policy close PRs whose comments read as generated. GREEN test drafted a full comment; that is the failure this line exists for.
- **CONTRIBUTING's tier list is the query order.** uv names `help wanted`, then `bug`, then everything else with a check-in. First three runs never queried `bug` at all and recommended only tier-3 issues. Read the tiers, query each tier in order.
- **Eight vetted candidates, not fourteen.** GREEN test vetted 14 because the cap was phrased as a stopping point for collection, not a ceiling for vetting. The cap is a ceiling.
