---
name: fall-2026-internship-autofill
description: Autofill and submit a Fall 2026 / autumn / co-op SWE internship application in the browser (Playwright MCP), then log it to Notion. Use for any job posting detected as a Fall 2026 internship or co-op.
---

# Fall 2026 Internship Autofill

Fill and submit one Fall 2026 internship application. Auto-submit ON — no confirmation needed before submitting.

## Term answers (override anything else)
- Start date: **Aug 24, 2026** (availability window ~Jan 15, 2027)
- Duration: longest offered (6 mo)
- Current student: **Yes**
- Graduation date to report: **December 2027** (intentional — do NOT match the résumé's May 2027). **Exception (confirm first):** if the posting requires a *later* grad (e.g. "must be graduating in 2028"), we *can* report **May 2028** to qualify (push graduation up to a year) — but do NOT enter it automatically. Pause as a human-in-the-loop checkpoint: hold the form filled, ask the user to confirm they still want to report May 2028 for this posting, and only enter it and submit after they say yes.
- Résumé to upload: **`resume/resume-templates/anirudh-resume-summer-2027.docx`** (user override — the summer-2027 file is used for Fall '26 too; .docx is fine, never convert to PDF)

## Standing answers
- Relocation **Yes** · remote/hybrid/onsite all OK · notice **Immediately**
- Sponsorship **No** · work-authorized **Yes** · previously employed there **No**
- EEO/demographics: **decline / prefer not to answer**
- GPA: **3.0/4.0** — required dropdowns: pick the truthful band containing 3.0; optional: decline/blank
- SAT/ACT: "I don't have" options where offered
- High school fields not on file: "Prefer not to disclose" / "Other" — never fabricate
- Compensation: "Open to market rate" unless a number is required
- "How did you hear": closest of LinkedIn / Website / Other
- Cover letter: skip unless required
- Portfolio / personal website URL: **https://anirudh-konidala.vercel.app/** (LinkedIn: https://www.linkedin.com/in/anirudh-konidala/ · GitHub: https://github.com/kidskoding)
- Niche checkboxes (math competitions etc.): the "none / not applicable" option

## Experience (résumé is primary; this is backup)
1. **T-Mobile** — SWE Intern (May–Aug 2026), ServiceNow Platform; AI agents + workflows for 70k+ employees
2. **Digital Cloud Systems** — SWE Intern (Jan–May 2026), FastAPI UCP API, WooCommerce/MySQL, Stripe, OAuth/JWT
3. **Sapience Inc** — GCP AI & Data Intern (Jun–Aug 2025), IAA title pipelines −90% prep time, Vertex AI +30% accuracy
4. **Seven Hills Holdings** — SWE Intern (Jun–Aug 2024), React/Next + Node CRE SaaS
- VP, Agentic AI @ UIUC (100+ members, 15+ agents, LangChain + RAG)
- Awards: Spring 2026 Illinois Stat Datathon 3rd/210; Claude Code Certified. **Never fabricate awards/publications/advisors.**

## Essays
Truthful, tailored to company/role, grounded in the experience above. Motivation ~150–200 words. Emphasize AI agents, scalable data systems, measurable impact (90% faster pipelines, 30% accuracy), end-to-end ownership.

## Browser workflow (Playwright MCP)
1. Prefer the direct ATS URL over the marketing page. Cross-origin iframe → `frameLocator`. Translations: Greenhouse `https://job-boards.greenhouse.io/<board>/jobs/<jobId>` or `.../embed/job_app?for=<board>&token=<jobId>`; Lever `https://jobs.lever.co/<company>/<id>/apply`. Unknown board + unreachable form → BLOCKED.
2. If the browser is shared with concurrent agents: create your OWN tab (`browser_tabs`) and re-select it before every action. If tab actions get hijacked or the profile is locked, drive a standalone Chrome via context-scoped Playwright code located by URL.
3. Upload résumé via `setInputFiles`. Dropdowns/typeaheads: click → type → pick. Multi-page: fill, Next, verify persistence.
4. Submit, verify the confirmation page/URL before claiming success.

## Hard stops (flag, never do)
No account creation, passwords, CAPTCHAs (incl. email verification codes), SSN/payment/government-ID. Disabled acknowledgment checkboxes (e.g. Tesla EEO): scroll into view and retry; if it still won't toggle, report BLOCKED naming the exact control. Privacy-preserving cookie options.

## Notion log (after successful submit)
**Confirm the term before you label it.** Only log as Fall '26 when the posting actually states or clearly implies a Fall 2026 / autumn / co-op term (season + year, an Aug/Sep 2026 start, or explicit "Fall 2026"). Many postings state no season — do NOT force "Fall '26" onto those. Decide the parenthetical:
- **Season stated/clear** → `<Team/area> - Fall '26` in the title.
- **No season, but a graduation-year/window requirement is stated** → keep the row here, but put the **grad window** in parens instead of a season: `(grad 2028)`, `(grad Winter 2027/Spring 2028)`, etc. If the posting **requires a later graduation** than our default (e.g. "must be graduating in 2028"), we can push graduation up to a year to qualify — but **confirm with the user before reporting May 2028** (see the graduation checkpoint above). Once confirmed, note `report grad May 2028` in **Other**. Only flag a real conflict if the required grad year is more than a year past our May 2027 baseline (or the user declines).
- **Neither season nor grad window stated** → `term UNCONFIRMED` in the title, `posting states no term` in **Other**, so it can be moved once known.

Fall '26 data source: `24431c9b-0b45-80c4-baac-000b172e475c` (this same tracker is also where term-unconfirmed rows are parked).
Row: **Name/Position** = `<Role> Intern (<Team/area> - <Fall '26 | grad window | term UNCONFIRMED>) - <Company>` · **Application Status** = `In progress` (exact casing) · submit date in **Other**. Skip silently if Notion MCP unavailable.

## Report
One line: `SUBMITTED — <Company>, <Role> (Fall '26), Notion: yes/no` or `BLOCKED — <Company>, <Role>: <reason>`.
