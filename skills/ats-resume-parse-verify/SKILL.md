---
name: ats-resume-parse-verify
description: After an ATS parses an uploaded résumé into structured Work Experience / Education fields (Workday "Autofill with Resume", Oracle Recruiting, Greenhouse/Lever parse, etc.), verify every parsed row and reformat/fix it before continuing. Use whenever an application autofilled fields from a résumé, or has pre-filled/structured experience fields — parsers routinely mangle titles, split/merge companies, drop the most-recent roles, and set wrong dates.
---

# ATS Résumé-Parse Verify & Reformat

Résumé parsers are unreliable. Any time an ATS fills structured fields from the résumé (or a saved profile pre-fills them), STOP and correct them before moving on. Never trust the parse. Never submit unverified.

Trigger: a step named "Autofill with Resume", "Parse résumé", "Review your information", or any pre-filled Work Experience / Education list.

## The check (do this every time)
1. **Read every parsed row** — Job Title, Company, currently-here flag, From/To dates — for all Work Experience and Education entries. Do not skim; read each field's actual value.
2. **Compare to the canonical experience below.** Fix any row whose title/company is mangled or truncated. Correct wrong dates.
3. **Add missing roles.** Parsers commonly drop the newest 1–2 jobs. If any canonical role is absent, use "Add Another" and fill it fully (title, company, dates, currently-here).
4. **Re-read the Review page** before Submit and confirm each row one last time.

## Canonical experience (source of truth — reverse-chronological)
1. **T-Mobile** — Software Engineer Intern — 05/2026–present (currently work here), ServiceNow Platform; AI agents + enterprise workflows for 70k+ employees
2. **Digital Cloud Systems** — Software Engineer Intern — 01/2026–05/2026, FastAPI UCP API, WooCommerce/MySQL, Stripe, OAuth/JWT
3. **Sapience Inc** — Google Cloud AI & Data Intern — 06/2025–08/2025, IAA title pipelines −90% prep time, Vertex AI +30% accuracy
4. **Seven Hills Holdings LLC** — Software Engineer Intern — 06/2024–08/2024, React/Next + Node CRE SaaS
- (Optional 5th) **Agentic AI @ UIUC** — VP — student org, 100+ members, 15+ agents, LangChain + RAG

Education: **University of Illinois Urbana-Champaign** — Bachelor's Degree, Computer Science. GPA 3.0/4.0 (only when required; decline when optional). Never fabricate.

## Known parser failure modes (seen in the wild)
- **Missing recent roles.** Fidelity/Workday autofill produced only 3 rows and dropped T-Mobile + Digital Cloud Systems entirely. Always add them back.
- **Mangled title/company splits.** e.g. "Agentic AI @" / "UIUC", or "Data Intern" / "Sapience Inc | Google Cloud AI". Reassign so Title and Company are clean and correct.
- **Wrong dates from a repurposed row.** If you retype a row for a different job, also fix its dates — don't leave the old month/year.

## Workday-specific date handling (important)
Workday From/To are `spinbutton` month/year inputs, NOT text boxes.
- Set month and year by typing into each spinbutton, then **verify with the input's `.value`** via `browser_evaluate` (ids look like `workExperience-<n>--startDate-dateSectionMonth-input` / `...-dateSectionYear-input`).
- A raw `fill('2026')` on the year has silently clamped to `2012` — always read back the value and retype if wrong.
- "I currently work here" checkbox drops the To field; check it for the ongoing role (T-Mobile).

## Other ATS notes
- **Oracle Recruiting Cloud / Taleo, Greenhouse, Lever, iCIMS:** same rule — after any résumé parse, read and correct the structured experience before Next/Submit.
- LinkedIn / portfolio / GitHub URL fields are often left blank by the parser — fill them: LinkedIn `https://www.linkedin.com/in/anirudh-konidala/`, portfolio `https://anirudh-konidala.vercel.app/`, GitHub `github.com/kidskoding`.

This skill only covers the parse-verify step. Term rules, standing answers, résumé-file selection, submit, and Notion logging come from the term-matched autofill skill (`fall-2026-internship-autofill` / `summer-2027-internship-autofill` / `new-grad-job-autofill`) and project CLAUDE.md.
