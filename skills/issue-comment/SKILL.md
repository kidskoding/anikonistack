---
name: issue-comment
description: Use when drafting a comment on a lore GitHub issue (EpicGames/lore) before opening a PR — structures the comment into a plain-language problem explanation, repro steps, and a suggested fix.
---

# Issue Comment

## Overview

A lore issue comment has exactly three parts, in this order: **Problem**, **Reproduce**, **Suggested fix**. Each section is short — a maintainer should be able to read the whole comment in under a minute.

## Structure

**1. Problem (plain language, no jargon dump)**
- What's broken, in terms a non-expert maintainer skimming issues could follow.
- Name the file/function/line involved, but lead with the plain-English symptom before the code reference.
- One short paragraph. If you need more than ~4 sentences, you're explaining the fix, not the problem — move that down.

**2. Reproduce**
- Concrete steps or a minimal code/CLI snippet that triggers the bug.
- Prefer copying an existing test/repro pattern from the repo if one exists (e.g. an existing `#[test]` you're extending) — cite it.
- State expected vs. actual behavior explicitly.

**3. Suggested fix**
- A concrete proposed change — not just "this should be fixed somehow."
- Name the function/file that would change and the shape of the fix (e.g. "swap `.unwrap()` for `?`", "branch on URL scheme").
- If the change touches auth, crypto, or wire format, flag that explicitly and ask for maintainer direction before coding — CONTRIBUTING.md requires this for security-sensitive or cross-cutting changes.
- If genuinely uncertain between two approaches, ask a direct either/or question rather than listing every option.

## Saving the draft

Every draft is a markdown file saved to `docs/issue-comments/issue-<number>.md` (e.g. `docs/issue-comments/issue-100.md`) before it is shown for review. The file contains exactly the comment body — no extra frontmatter or notes — so it can be posted verbatim with:

```
gh issue comment <number> --repo EpicGames/lore --body-file docs/issue-comments/issue-<number>.md
```

`docs/issue-comments/` is ignored via `.git/info/exclude` (local-only, never committed). If the directory or exclude entry is missing, create both:

```
mkdir -p docs/issue-comments
grep -qxF 'docs/issue-comments/' .git/info/exclude || echo 'docs/issue-comments/' >> .git/info/exclude
```

Revisions from review go into the same file — edit it, don't fork a second copy.

## AI disclosure

CONTRIBUTING.md requires disclosing AI tool use. If Claude helped draft the comment, end it with:

```
(Disclosure: drafted with Claude's help, reviewed by me before posting.)
```

## Example

See lore issue #32 (JWK `file://` support) — drafted with this structure: problem (endpoint assumes HTTP, no scheme check), reproduce (n/a, described as missing capability instead), suggested fix (branch on scheme, reuse existing `JWKService` trait, flagged as security-sensitive with a direct question on config shape).

## Common mistakes

- Skipping straight to the fix without stating the problem in plain terms first — maintainers triage by problem, not by patch.
- Vague repro ("sometimes this fails") instead of concrete steps or a snippet.
- Proposing a fix without naming the actual file/function that changes.
- Forgetting the AI disclosure line when Claude drafted the comment.
