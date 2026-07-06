---
name: eli5
description: Explain any concept, course module, or certification topic ELI5-style. Fetches official content when possible. Usage: /eli5 <topic> | /eli5 course <cert> [--quiz] | natural language like "explain module 1 of ServiceNow Advanced Fundamentals"
when_to_use: Use whenever the user wants a concept made clear — no slash command required. Triggers include: typing /eli5; "explain X eli5" / "ELI5 X" / "explain it like I'm five"; plain "explain X", "what is X", "how does X work", "tell me about X", "break down X", "help me understand X"; asking for a study guide or to explain a certification (e.g. "course databricks"); or walking through a specific module/lesson/section of a named course. Prefer this skill for any "explain/understand a topic" request unless the user is clearly asking only for code changes or debugging.
---

# eli5

The full eli5 behavior lives in **`AGENTS.md`** — the single source of truth. It sits in **this skill's
base directory** (the same folder as this `SKILL.md`). Read that `AGENTS.md` and follow its instructions
exactly.

In short: detect the mode (Module / Course / Single Topic) from the user's invocation, honor any
`--quiz` flag, explain the topic ELI5-style with real depth, then offer to save per the **"Saving notes"**
rules in `AGENTS.md` — which present an interactive destination picker (current folder, `~/.claude/eli5-notes/`,
Microsoft Word, or Notion).
