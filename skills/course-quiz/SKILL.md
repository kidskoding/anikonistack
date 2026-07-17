---
name: course-quiz
description: >-
  Drive an online-course quiz, exam, or final assessment in the Playwright browser
  and complete it reliably — discover the question DOM, answer each question, submit,
  and report the score. Platform-agnostic: works on Coursera, edX, Udemy,
  Skilljar/Anthropic Academy, Google/Cloud Skills Boost, Canvas/Moodle LMS, and most
  web quizzes, whether one-question-at-a-time or all-questions-on-one-page. Use when
  the user says "do the exam/quiz in playwright", "take the final assessment / knowledge
  check", "answer the quiz for me", "get the certificate", or points at a graded course
  assessment. Handles single-select, multi-select, opinion/survey items, and free-text,
  and keeps the user in the loop on every answer.
---

# Course quiz → complete it in Playwright

Reliably take an online-course quiz/exam in the Playwright browser and report the
result, on **any** platform. Quiz DOMs differ, so the method is **discover first,
then act** — inspect the page to find the option controls and the advance/submit
button, rather than assuming one platform's markup. Platform-specific hints and a
fully worked Skilljar recipe are below.

## Ground rules (read first)

- **It's the user's own credential.** The certificate/grade attests *they*
  completed the course. Only do this when the user asks. Free, open-book
  completion checks are fine to tutor through; a **proctored, for-credit, or
  professional certification exam is not** — if the page mentions proctoring, an
  honor code you'd be violating, academic credit, or a paid certification, stop
  and say so.
- **Keep the user in the loop.** For every graded question, report the question,
  the answer you're choosing, and a one-line reason (ideally tied to their course
  notes). You're tutoring on their behalf, not silently farming a badge.
- **Don't fabricate the user's voice.** Free-text answers you can't derive → ask
  or leave blank. Opinion/satisfaction/NPS survey items → neutral-positive default,
  and **tell the user what you chose**.
- **Submit is the point of no return.** Confirm every graded question is answered
  first. Note any attempt limits (some platforms cap retakes / lock after submit).

## Prerequisites

- **Playwright MCP** connected and **logged in** to the course site in that
  browser (a separate session from the user's own). Verify you're authed (look for
  the user's name / a "Sign Out"/"Log Out" control; absence of a "Sign In" wall).
  If not, ask the user to log in in the Playwright window.
- Know the answers: for a course you just took notes on, the notes are the answer
  key. Otherwise reason from the material and the options.

## Workflow

### 1. Open the quiz and discover its shape
`browser_navigate` to the quiz page, then **snapshot the DOM** to learn: is it one
question at a time or all on one page? Are options `<input type=radio>` /
`type=checkbox`, ARIA `role="radio"`/`"checkbox"`, or clickable `<label>`/`<div>`s?
What's the advance/submit control labelled?

```js
() => {
  const radios = document.querySelectorAll('input[type=radio]').length;
  const checks = document.querySelectorAll('input[type=checkbox]').length;
  const ariaOpts = document.querySelectorAll('[role=radio],[role=checkbox]').length;
  const labels = Array.from(document.querySelectorAll('label')).slice(0, 12).map(l => l.textContent.trim().slice(0, 80));
  const btns = Array.from(document.querySelectorAll('button,a,input[type=submit]'))
    .map(b => (b.textContent || b.value || '').trim()).filter(t => /next|submit|continue|check|finish|start|question/i.test(t)).slice(0, 12);
  const progress = (document.body.innerText.match(/Question \d+ of \d+|\d+\s*\/\s*\d+/) || [])[0] || '?';
  return JSON.stringify({ radios, checks, ariaOpts, oneAtATime: /Question \d+ of \d+/.test(document.body.innerText), progress, labels, btns }, null, 2);
}
```

- `oneAtATime` true (Skilljar, Udemy, many LMS) → loop steps 2–3 per question.
- All-on-one-page (many Coursera/edX/Cloud Skills Boost) → answer every question,
  then one Submit (step 3b).
- `checks > 0` or multiple `role=checkbox` in a group → **multi-select**: select
  *all* correct options, not one.

### 2. Read the current question (one-at-a-time)

```js
() => {
  const root = document.querySelector('.course-text-content, .quiz, [class*=question], main') || document.body;
  const q = root.innerText;
  const m = q.match(/Question \d+ of \d+/);
  const stem = (m ? q.split(m[0])[1] : q).slice(0, 500);
  const options = Array.from(document.querySelectorAll('label,[role=radio],[role=checkbox]'))
    .map(l => l.textContent.trim().split('\n')[0]).filter(Boolean);
  return JSON.stringify({ progress: m ? m[0] : '?', stem, options, hasTextarea: !!document.querySelector('textarea') }, null, 1);
}
```

Report **Q#**, the question, options, and your chosen answer + reason. Then advance.

### 3. Select the answer and advance

Choose the mechanism that matches what step 1 found. Pass a **distinctive
substring** of the correct option; for lookalike single-word options (e.g.
"Description" vs "Discernment") use an **exact** match.

```js
(correctSubstr, exact) => {
  const norm = s => (s || '').toLowerCase().trim();
  const hit = el => exact ? norm(el.textContent) === norm(correctSubstr) : norm(el.textContent).includes(norm(correctSubstr));
  // 1) native label+radio
  const lbl = Array.from(document.querySelectorAll('label')).find(hit);
  if (lbl && lbl.htmlFor) document.getElementById(lbl.htmlFor).click();
  // 2) ARIA option or clickable label/div (React/Coursera/edX)
  else { const o = Array.from(document.querySelectorAll('[role=radio],[role=checkbox],label,li,button')).find(hit); if (o) o.click(); }
  const nav = Array.from(document.querySelectorAll('button,a,input[type=submit]'))
    .find(b => /next question|next|continue|^submit$/i.test((b.textContent || b.value || '').trim()));
  if (nav) nav.click();
  return 'advanced';
}
```

- **Wrapped-radio survey scale** (empty `htmlFor`): select by index instead —
  `document.querySelectorAll('input[type=radio]')[idx].click()` (neutral-positive
  default), then click Next.
- **Free-text** (`hasTextarea`): leave blank (or fill only if the answer is
  derivable), then advance.

Loop 2–3 until the last question, then Submit. Do these as **separate calls**
(read → report → pick+advance → read next); more robust than one mega-loop and
lets you report each answer.

### 3b. All-on-one-page variant
Enumerate all question blocks, select the correct option within each (by matching
option text near each question stem), then click the single **Submit**. Re-snapshot
before submitting to confirm every question has a selection.

### 4. Read the result

```js
() => {
  const t = document.body.innerText;
  const m = t.match(/(passed|failed|congratulat[^.]*)|(\d+\s*(?:of|\/|out of)\s*\d+)|(\d+%)/gi);
  return JSON.stringify({ passed: /pass|congratulat/i.test(t) && !/did not pass|fail/i.test(t), matches: m, snippet: t.slice(0, 400) }, null, 1);
}
```

Report the score and any survey defaults you chose. On pass, the certificate is
usually on the course page / the user's profile / an "Accomplishments" area. If a
graded answer was wrong and the platform allows it, use **"Take this again" /
"Retake"** and fix that answer.

## Platform hints

| Platform | Shape | Options | Advance / submit |
|----------|-------|---------|------------------|
| **Skilljar / Anthropic Academy** (`*.skilljar.com`) | one-at-a-time | `label[htmlFor]` + `input[type=radio]`; survey scales are wrapped radios | "Next Question" then "Submit"; result shows `N of N Correct (100%)` |
| **Coursera** | usually all-on-one-page (React) | `role=radio`/`role=checkbox` or `input`; multi-select common | "Submit"; grade + "Check your grade" after |
| **edX** | per-problem blocks | `input[type=radio/checkbox]` inside `.problem` | "Submit" per problem; check/✓ feedback inline |
| **Udemy** | one-at-a-time | `input[type=radio]` + label | "Check answer" / "Next"; some allow skip |
| **Cloud Skills Boost / Google** | one-page form | `role=radio` / checkboxes | "Submit"; per-question ✓/✗ |
| **Canvas / Moodle (LMS)** | one-page or paged | `input[type=radio/checkbox]` | "Submit Quiz" / "Next Page" |
| **Generic / unknown** | discover via step 1 | whatever step 1 finds | button matching next/submit/continue |

Always trust **step-1 discovery** over the table — markup changes.

## Gotchas (learned the hard way)

- **Playwright target closed** between calls: re-`browser_navigate` to the quiz URL
  and continue; the login session survives. (Restarting a one-at-a-time quiz resets
  to Q1 — you re-answer, which is fine.)
- **Escaped double-quotes** (`\"`) inside a `browser_evaluate` function string can
  break serialization ("Invalid or unexpected token"). Use single quotes, or
  `String.fromCharCode(34)`/`(39)`, and `.split().join()` over `.replace()`.
- **Lookalike options**: match exact label text for single-word choices that are
  substrings of each other.
- **Multi-select**: when the question says "select all that apply" or the controls
  are checkboxes, select every correct option — don't stop at one.
- **React/SPA quizzes** may need a click on the option's container (not a hidden
  input) and a short settle before the Next button enables; re-read if Next didn't
  advance.
- **Login is per-Playwright-session**, never the user's own browser — verify auth
  before starting.
- Assessments often mix graded MCQs with ungraded satisfaction/NPS/free-text items;
  only the graded MCQs affect the score.
