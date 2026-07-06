---
name: coursera-notes
description: Use when the user wants thorough notes from a Coursera course taken into Notion — "take notes from this Coursera course", "coursera to notion", "note the videos in <course>", or points at an open Coursera course and asks for study notes. Mirrors the course's Specialization→Course→Module→Lesson→Video hierarchy as nested Notion pages and writes self-contained study-guide notes from each video's transcript.
usage: /coursera-notes  (have the course open + be logged in to Coursera in the Playwright browser first)
triggers:
  - "take notes from coursera", "coursera to notion", "note the videos"
  - "take notes on <course> into notion"
requires: Playwright MCP (browser control) + Notion MCP (page creation), user logged in to Coursera in the Playwright-controlled browser
---

# Coursera → Notion Notes

Turn a Coursera course into a nested Notion page tree with **thorough, self-contained study notes** — notes that still make perfect sense months later without rewatching the video.

## Core principle

Notes are a **study guide, not a transcript dump**. The bar: the user must be able to read them **years later** and fully understand the material without the video. Every note stands alone —

- **Define every term the first time it appears** (AI, model, training data, LLM, GenAI, multimodal, agent, …). Don't assume prior knowledge.
- **Explain the mechanism**, not just the name — *how* it works and *why* it matters.
- **Keep every concrete example** the speaker gave (the apple-sorting model, the spam filter). Examples are what make it stick years later; never drop them for brevity.
- **End with takeaways**, and add a **glossary** (`> **Terms:** …`) whenever jargon appeared.

Depth scales with content: a dense conceptual lecture gets full sections and a glossary; a 40-second tip gets a tight few bullets. Thoroughness means *completeness of understanding*, never padding. If a note only makes sense while watching, it failed.

## Prerequisites (check first, don't assume)

1. **Playwright MCP + Notion MCP** both connected.
2. **Logged in to Coursera** in the Playwright browser. The Playwright browser is a *separate instance* from the user's own browser — cookies do NOT carry over. Snapshot the page; if you see a "Log In" button, ask the user to log in inside that browser window before continuing.
3. **Target Notion location** confirmed with the user (which parent page the course tree goes under).

## Workflow

### 1. Map the course structure
Navigate the course home (`/learn/<slug>/home/module/1`). Enumerate the hierarchy from the sidebar + module pages:

```
Specialization / Professional Certificate   (a page, if the course is part of a multi-course program)
└─ Course
   └─ Module          (Coursera "Module N"; page icon = keycap number 1️⃣ 2️⃣ …)
      └─ Item          (Video AND Reading, one subpage each, in Coursera order)
```
If it's a specialization, put each Course page under the Specialization page and add courses to the **same** Specialization page as you complete them (don't make a new one per course). A standalone course skips the Specialization level.

Collect each **video's** title, duration, and lecture URL (`/learn/<slug>/lecture/<id>/<slug>`). A module page lists items as links with `/lecture/` (video) or `/supplement/` (reading) in the href.

### 2. Build the Notion tree (top-down, before writing notes)
Create pages with `notion-create-pages`, parenting each level under the one above:
- Course page → under the user's chosen parent
- Module page → under Course
- Lesson page → under Module
- Video page → under Lesson

Give each level a short intro (module = its learning objectives; lesson = one-line scope). Keep the video page empty until step 3. **Match Coursera's real names exactly** so it's recognizable later.

**Module page icons:** use the keycap number emoji matching the module number — Module 1 → 1️⃣, 2 → 2️⃣, 3 → 3️⃣, 4 → 4️⃣, 5 → 5️⃣, 6 → 6️⃣, … 10 → 🔟. Not themed/topic emojis.

**Item ordering:** create one subpage per item (video AND reading) directly under its module, in the exact order Coursera lists them. Prefix each title with its position (`1.`, `2.`, …) and suffix the kind (`(Video)` / `(Reading)`). Don't group by lesson or media type unless the user asks.

Don't force a level that doesn't exist: mirror what Coursera actually shows.

### 3. Per video: extract transcript → write notes
For each video URL:

a. `browser_navigate` to the lecture URL.

b. Click the **Transcript** button, then extract with this proven snippet (`browser_evaluate`):

```js
() => {
  const btn = Array.from(document.querySelectorAll('button'))
    .find(b => /^transcript$/i.test(b.textContent.trim()));
  if (btn) btn.click();
  const phrases = Array.from(document.querySelectorAll('[class*="phrase"]'))
    .map(e => e.textContent.replace(/​/g, '').trim())
    .filter(Boolean)
    .filter(t => !/^Play video starting at/i.test(t));   // drop aria labels
  const clean = [];
  for (const p of phrases) if (p !== clean[clean.length - 1]) clean.push(p); // dedup
  return JSON.stringify({ chars: clean.join(' ').length, transcript: clean.join(' ').replace(/\s+/g, ' ').trim() });
}
```
If `chars` is 0, the Transcript panel didn't open — snapshot, find the real toggle, retry. Never write notes from an empty transcript.

c. Write the transcript into the video's Notion page using the **note template** below. Synthesize — do not paste the transcript.

### Note template (per video page)
```markdown
## <Video title>  ·  <duration>  ·  [Watch](<lecture URL>)

**In one line:** <what this video is about + why it matters>

### Key ideas
- **<Term / concept>** — <plain-language definition, then why it matters>
- ...

### Details & examples
<Prose or bullets covering the actual content: mechanisms, steps,
concrete examples the speaker gave. Enough that the reader learns the
material here without the video.>

### Takeaways
- <Actionable / memorable point>
- ...

> **Terms:** <term> = <definition>; ...   ← only if jargon appeared
```

Adapt depth to length: a 1-min intro gets a few bullets; a 10-min lecture gets full sections. Thoroughness scales with content, never padding.

## Quick reference

| Step | Tool | Note |
|------|------|------|
| Check login | `browser_snapshot` | "Log In" button = not authed, ask user |
| Enumerate videos | `browser_snapshot` on module pages | `/lecture/` = video, `/supplement/` = reading |
| Create tree | `notion-create-pages` | parent each level under the one above |
| Get transcript | `browser_evaluate` (snippet above) | click Transcript first; verify `chars>0` |
| Write notes | `notion-update-page` / create with content | study guide, not transcript |

## Common mistakes
- **Pasting the transcript** instead of synthesizing → useless months later. Write a study guide.
- **Assuming logged in** → Playwright browser has its own session. Verify.
- **Forcing 4 levels** when a module has one lesson → mirror Coursera's actual shape.
- **Writing from empty transcript** → always check `chars>0` before writing.
- **Renaming things** → keep Coursera's exact titles so the tree is recognizable.
- **Doing all pages then all notes with no checkpoint** → build tree, then do notes module-by-module so a failure loses little.
