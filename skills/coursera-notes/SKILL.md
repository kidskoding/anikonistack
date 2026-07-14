---
name: coursera-notes
description: Use when the user wants thorough study notes from an online course (Coursera, Udemy, edX, YouTube playlist, LinkedIn Learning, Pluralsight, a school LMS, or any video/reading course) captured to their chosen destination — Notion, Obsidian, local markdown files, or Google Docs. "take notes from this course", "course to notion/obsidian/markdown", "note the videos in <course>", or points at an open course and asks for study notes. Mirrors the course's real hierarchy at the destination and writes self-contained study-guide notes from each item's transcript or text.
usage: /coursera-notes  (have the course open + be logged in on that platform in the Playwright browser first)
triggers:
  - "take notes from this course", "course to notion", "course to obsidian", "course to markdown", "note the videos"
  - "take notes on <course> into <notion|obsidian|markdown|google docs>"
  - points at any open course (Coursera, Udemy, edX, YouTube, LMS, …) and asks for notes
requires: Playwright MCP (browser control), user logged in to the course platform in the Playwright-controlled browser. Destination-dependent — Notion MCP (Notion), Google Drive MCP (Google Docs), or filesystem only (Obsidian / local markdown).
---

# Course → Notes (Notion · Obsidian · Local markdown · Google Docs)

Turn **any** online course into a hierarchy of **thorough, self-contained study notes** at the destination the user picks — notes that still make perfect sense months later without rewatching the video. Works for Coursera, Udemy, edX, YouTube playlists, LinkedIn Learning, Pluralsight, a university LMS, or any site that exposes lecture videos/readings.

The note **content** (markdown study guide) is identical everywhere — only *where it lands* changes. See [Destinations](#destinations) for the per-target write mechanism.

## Core principle

Notes are a **study guide, not a transcript dump**. The bar: the user must be able to read them **years later** and fully understand the material without the video. Every note stands alone —

- **Define every term the first time it appears** (AI, model, training data, LLM, GenAI, multimodal, agent, …). Don't assume prior knowledge.
- **Explain the mechanism**, not just the name — *how* it works and *why* it matters.
- **Keep every concrete example** the speaker gave (the apple-sorting model, the spam filter). Examples are what make it stick years later; never drop them for brevity.
- **End with takeaways**, and add a **glossary** (`> **Terms:** …`) whenever jargon appeared.

Depth scales with content: a dense conceptual lecture gets full sections and a glossary; a 40-second tip gets a tight few bullets. Thoroughness means *completeness of understanding*, never padding. If a note only makes sense while watching, it failed.

## Prerequisites (check first, don't assume)

1. **Pick the destination first.** Ask the user where notes go if not already stated: **Notion**, **Obsidian**, **local markdown** (`./notes` folder in the current directory), or **Google Docs**. This decides which MCP/tools you need and how the tree is built (see [Destinations](#destinations)).
2. **Playwright MCP** connected + the destination's tool available: Notion MCP (Notion), Google Drive MCP (Google Docs), or just the filesystem (Obsidian / local markdown — no MCP needed).
3. **Logged in to the course platform** in the Playwright browser. The Playwright browser is a *separate instance* from the user's own browser — cookies do NOT carry over. Snapshot the page; if you see a "Log In" / "Sign In" button or a paywall, ask the user to log in inside that browser window before continuing. (Public YouTube playlists usually need no login.)
4. **Target location** confirmed with the user — the Notion parent page, the Obsidian vault path, the `./notes` subfolder name, or the Google Drive folder.

## Workflow

### 1. Map the course structure
Navigate the course home and enumerate the hierarchy from the sidebar / curriculum / module pages. Course platforms name levels differently — map whatever the platform uses onto this generic shape:

```
Program            (Specialization / Professional Certificate / Track / Path — a page, only if the course is part of a multi-course program)
└─ Course
   └─ Section       (Coursera "Module N" · Udemy "Section" · edX "Week" · YouTube = the playlist itself; icon = keycap number 1️⃣ 2️⃣ …)
      └─ Item        (Video AND Reading/Article/Quiz, one subpage each, in the platform's order)
```
If it's a multi-course program, put each Course page under the Program page and add courses to the **same** Program page as you complete them (don't make a new one per course). A standalone course skips the Program level.

Collect each **video's** title, duration, and direct lecture/watch URL. Platform hints for spotting item type in links:
- **Coursera** — home `/learn/<slug>/home/module/1`; `/lecture/` = video, `/supplement/` = reading.
- **Udemy** — `/course/<slug>/learn/lecture/<id>`; curriculum sidebar lists lectures with a play icon vs. article/quiz icon.
- **edX** — unit pages under a section/subsection; video blocks vs. HTML/problem blocks.
- **YouTube playlist** — each `watch?v=…&list=…` entry is one video; the playlist is the single Section.
- **Other/LMS** — snapshot the sidebar and infer from icons/labels (play triangle = video, doc = reading).

### 2. Build the note tree (top-down, before writing notes)
Create the hierarchy at the chosen destination — one node per level (Course → Section → [Lesson] → Item), parenting each under the one above. **How** you create a node depends on the destination; see [Destinations](#destinations) for the exact tool and nesting for Notion / Obsidian / local markdown / Google Docs. The tree *shape* below is the same everywhere:
- Course → under the user's chosen parent (Notion page · vault/`./notes` subfolder · Drive folder)
- Section → under Course
- (Lesson → under Section, only if the platform groups items into lessons)
- Item → under Section (or Lesson)

Give each level a short intro (section = its learning objectives; lesson = one-line scope). Keep item nodes empty until step 3. **Match the platform's real names exactly** so it's recognizable later.

**Module/section summary (always):** every section/module node ends with a `## Summary` (or `### Summary`) section that recaps the whole module in a few sentences — the throughline of what it taught, tying its lessons together. Write this **after** the module's item notes exist (append it once you know the full arc), so it's a real recap, not a preview. This applies to every course.

**Section icons/labels:** for Notion, use the keycap number emoji matching the section number — 1 → 1️⃣, 2 → 2️⃣, 3 → 3️⃣, 4 → 4️⃣, 5 → 5️⃣, 6 → 6️⃣, … 10 → 🔟 (not themed/topic emojis). For file-based destinations, prefix the folder/file name with the zero-padded number (`01-…`, `02-…`) so it sorts.

**Item ordering:** create one node per item (video AND reading/quiz) directly under its section, in the exact order the platform lists them. Prefix each title with its position (`1.`, `2.`, …) and suffix the kind (`(Video)` / `(Reading)` / `(Quiz)`). Don't group by lesson or media type unless the user asks.

Don't force a level that doesn't exist: mirror what the platform actually shows.

### 3. Per video: extract transcript → write notes
For each video URL:

a. `browser_navigate` to the lecture/watch URL.

b. Open the transcript/captions panel, then extract the text. The snippet below is the **Coursera** extractor; for other platforms, adjust the selector (see table). General approach: click the Transcript/CC toggle, grab the caption cue elements, dedup consecutive repeats, join.

```js
// Coursera
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

Per-platform transcript source:

| Platform | How to get transcript |
|----------|----------------------|
| Coursera | Click **Transcript** button; cues in `[class*="phrase"]` (snippet above) |
| Udemy | Click **Transcript** (top-right of player); cues in `[data-purpose="transcript-cue"]` |
| edX | Transcript is beside the video (`.subtitles` / downloadable `.srt` link) |
| YouTube | "…more" → **Show transcript**; cues in `ytd-transcript-segment-renderer` |
| Other | Snapshot, find the CC/transcript toggle, grab the caption cue nodes; adapt the snippet's selector |

If `chars` is 0, the transcript panel didn't open (or the video has no captions) — snapshot, find the real toggle, retry. If the video genuinely has no transcript, tell the user and fall back to on-screen slide text / their notes rather than inventing content. **Never write notes from an empty transcript.**

c. Write the notes into the item's node (Notion page / `.md` file / Google Doc — see [Destinations](#destinations)) using the **note template** below. The markdown is identical across destinations. Synthesize — do not paste the transcript.

### Note template (per video item)
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

### Summary
<A few-sentence recap of this item — the throughline, readable on its own.>

> **Terms:** <term> = <definition>; ...   ← only if jargon appeared
```

Every item node (video AND reading) ends with a `### Summary` section — a short standalone recap of that lesson. And every module/section node ends with a summary too (see step 2). Both are standard for all courses.

Adapt depth to length: a 1-min intro gets a few bullets; a 10-min lecture gets full sections. Thoroughness scales with content, never padding.

## Destinations

Same note markdown everywhere; only the create/write mechanism and nesting differ. Confirm the target with the user (prereq 4) before building the tree.

| Destination | Tree = | Create / write with | Notes |
|-------------|--------|---------------------|-------|
| **Notion** | Nested pages | `notion-create-pages` (tree), `notion-update-page` (notes) | Parent each level under the one above. Section icon = keycap number emoji. |
| **Obsidian** | Nested folders + one `.md` per node, plus an index note per folder | `Write` tool; follow the **obsidian-vault** skill for vault path, wikilinks, and index notes | Link items from the section index with `[[wikilinks]]`. Number-prefix names to sort. |
| **Local markdown** | Nested folders under `./notes/<Course>/` + one `.md` per node | `Write` tool | `./notes` = a folder named `notes` in the user's current working directory. Same layout as Obsidian but plain relative-path links (`[title](01-item.md)`), no vault. Create `./notes` if absent. |
| **Google Docs** | Nested Drive folders + one Google Doc per item | Google Drive MCP `create_file` (mimeType `application/vnd.google-apps.document`) for each folder/Doc | One Doc per item is simplest; a section "index" Doc holds the intro + summary. Docs don't nest, so the folder tree carries the hierarchy. |

For **Obsidian**, defer to the `obsidian-vault` skill for the vault's conventions rather than re-specifying wikilink/index mechanics here.

Folder/file layout for file-based destinations (Obsidian / local markdown):
```
notes/<Course>/
  00-index.md                 ← course intro
  01-<Section>/
    00-index.md               ← section objectives + Summary
    01-<Item> (Video).md
    02-<Item> (Reading).md
  02-<Section>/ …
```

## Quick reference

| Step | Tool | Note |
|------|------|------|
| Pick destination | ask user | Notion · Obsidian · local `./notes` markdown · Google Docs (prereq 1) |
| Check login | `browser_snapshot` | "Log In"/"Sign In"/paywall = not authed, ask user |
| Enumerate items | `browser_snapshot` on section/curriculum pages | infer video vs. reading from link/icon (see platform hints) |
| Create tree | destination tool (see [Destinations](#destinations)) | parent each level under the one above |
| Get transcript | `browser_evaluate` (snippet + platform table above) | open transcript first; verify `chars>0` |
| Write notes | destination tool (see [Destinations](#destinations)) | study guide, not transcript |

## Common mistakes
- **Pasting the transcript** instead of synthesizing → useless months later. Write a study guide.
- **Assuming logged in** → Playwright browser has its own session. Verify.
- **Assuming Notion** → ask where notes go first; only Notion needs the Notion MCP.
- **Forcing 4 levels** when a section has one lesson → mirror the platform's actual shape.
- **Writing from empty transcript** → always check `chars>0` before writing.
- **Renaming things** → keep the platform's exact titles so the tree is recognizable.
- **Doing all pages then all notes with no checkpoint** → build tree, then do notes section-by-section so a failure loses little.
