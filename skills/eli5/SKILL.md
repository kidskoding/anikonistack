---
name: eli5
description: >-
  Explain any concept, course module, or certification topic ELI5-style with real
  depth; fetches official content when possible. Use when the user types /eli5,
  says "explain X eli5", "ELI5 X", "explain it like I'm five", "what is X",
  "how does X work", "break down X", asks for a study guide or cert walkthrough
  (e.g. "course databricks"), or wants a specific module of a named course
  explained. Prefer over ad-hoc explanation unless the user only wants code changes. Not for
  how the current project works or rehearsing it for an interview or demo (project-journal
  Teach Mode handles that), or a multi-session course (/teach).
---

# eli5

The full eli5 behavior lives in **`AGENTS.md`** in this skill's directory (next to
this `SKILL.md`). Read that file and follow it exactly.

In short: detect the mode (Module / Course / Single Topic), honor any `--quiz`
flag, explain ELI5-style with real depth, then offer to save per **"Saving notes"**
in `AGENTS.md` (current folder, `~/.claude/eli5-notes/`, Microsoft Word, or Notion).

## Invocation

| Form | Mode |
|------|------|
| `/eli5 <topic>` or "explain X" / "what is X" | Single Topic |
| `/eli5 course <cert> [--quiz]` | Course study guide |
| "explain module 1 of …" / named module in a course | Module |
