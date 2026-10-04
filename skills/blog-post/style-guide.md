# Style Guide

How the user's developer posts should read. Apply in every Editor-mode stage from Stage 2 on.

## What a Post Is Not

- a résumé rewritten as prose
- "5 things I learned at my internship"
- a diary of everything done this week
- documentation with an introduction attached
- a list of technologies used
- an overly polished LinkedIn post
- a tutorial, unless the user asks for one

## Internship and Job Posts

Strongly discourage chronological reporting.

BAD:

```text
During my first month I worked with:
- Cloudflare Workers
- Effect
- Drizzle
- Nix

First I did X. Then I did Y. Then I learned Z.
```

BETTER: find the idea connecting those experiences. The article is about the idea. The internship is where the author discovered it.

## Technology as Evidence

Technology supports the argument. Never structure a post as "What is Effect? What is Nix? What are Workers? Conclusion." That is documentation.

Instead:

```text
claim → real engineering situation → technology involved
      → what the technology exposed → lesson → next situation
```

Explain only enough for the reader to see why the decision was interesting. Assume a technically curious reader who may not know every tool. 100 words plus a diagram beats 500 words of API tour.

## Concrete Moments

Abstract engineering writing gets boring fast. Anchor every section in a moment:
- "I thought I understood Drizzle until I had to integrate it with Effect."
- onboarding another developer
- discovering undocumented machine dependencies
- reproducing a build on another machine
- a failure handled differently than expected
- realizing a Worker should not depend on process-local state
- replacing a long setup guide with a reproducible environment
- debugging an integration boundary
- an abstraction behaving differently in production

Useful pattern for reflective writing:

```text
I expected X.
Then Y happened.
That forced me to understand Z.
```

## Technical Depth

Do not dumb down the engineering. Another developer should learn something. Good material: architecture and dependency diagrams, small code snippets, before/after designs, simplified data flows, type signatures, config snippets, failure scenarios, trade-offs.

Every technical element must answer: **why does this matter to the thesis?** Cut details that only prove the author knows them.

Snippets: 5–30 lines, trimmed with `// ...`, language tag on every fence, explained after the code. Use `diff` fences for before/after.

## Diagrams

Recommend diagrams aggressively when a relationship is visual. Use Mermaid only when the target renders it (the portfolio does not; see `portfolio.md`). Otherwise draw them as ASCII in ```` ```text ```` fences.

- **Architecture:** `Client → Worker → Service → Database`
- **Dependency boundaries:** `Business Logic → Database Service → Drizzle → Database`
- **Conceptual transformation:** `something familiar → new environment → hidden assumption → deeper understanding`
- **Before / after:**

```text
README instructions        Nix environment
       ↓                         ↓
manual machine state       declared environment
```

Diagrams communicate an idea, never decorate. No giant diagrams. Readable in a few seconds.

## Voice

Thoughtful, conversational, technically competent. A developer thinking through something they actually encountered.

The author:
- enjoys software engineering and likes knowing why tools are designed the way they are
- cares about developer tooling and architecture
- likes Nix, Rust, modern TypeScript tooling, infrastructure, and unusual technical ideas
- questions their own previous assumptions and is still learning
- prefers interesting ideas over prestige or corporate branding

Not personal branding. The technical idea is the interesting part.

**Prefer:** short paragraphs, clear sentences, occasional fragments for emphasis, specific language, natural first-person reflection, confidence without pretending to know everything, sections that flow into each other, rhetorical questions when useful, code and diagrams between prose.

**Avoid:** corporate marketing language, fake enthusiasm, piles of adjectives, motivational LinkedIn tone, "I'm thrilled to announce", "In today's rapidly evolving technological landscape", generic AI introductions, constant bullet lists, unnecessary headings, the thesis repeated word for word in every section, excessive em dashes, a motivational line closing every section.

## Professional Reflection

One month of experience is not universal expertise. Share an evolving mental model:
- "One thing I've started appreciating..."
- "This changed how I think about..."
- "The model that clicked for me was..."
- "I'm beginning to see..."
- "The interesting part, at least from what I've worked with so far..."

## Openings

Never: "It has officially been one month since I joined COMPANY, and I've learned so much!"

Open with a realization, a contradiction, a technical problem, a surprising statement, or a concrete moment:

> I knew what Drizzle ORM was before starting this job.
>
> Then I had to integrate it with Effect.
>
> And suddenly I wasn't sure I actually knew Drizzle.

That creates a question. Reveal the job or internship context gradually after it.

## Endings

Never a generic summary ("Overall, my first month has been an incredible learning experience...").

Return to the opening idea. The final paragraph compresses the article into a thought worth remembering and makes the title feel inevitable:

```text
I thought learning meant encountering something new.

This month reminded me that sometimes learning means
returning to something familiar under a new constraint.

Learn it.
Use it.
Connect it to something unfamiliar.
Discover the assumptions you didn't know you were making.
Learn it again.
```

## Titles

Idea-driven, not employer-driven. The job goes in the subtitle.

Weak: "My First Month at Brunswick", "What I Learned During My First Month", "My Software Engineering Internship Experience".

Better: "Learn It Again", "One Month In: Learn It Again", "The Things Your Development Environment Isn't Telling You", "Reproducibility Is a Team Feature", "Learning Happens at the Seams", "Making Assumptions Explicit".

Example pair:
- title: `Learn It Again`
- description: `What Effect, Nix, and Cloudflare Workers taught me during my first month at Brunswick`

## Example Theses

- "Good systems make their assumptions explicit."
- "Using a tool teaches you its API. Integrating it teaches you its model."
- "Reproducibility is not a developer convenience. It's a team feature."
- "The interesting engineering happens at the boundaries between systems."
- "You haven't necessarily learned a technology just because you've used it before."

## Company Context and Confidentiality

Use company context only when it explains why a pattern is interesting. Prefer framing like "In a company operating across many products and digital experiences..." over describing internal topology.

**Confidentiality check.** Flag anything that reveals:
- proprietary architecture or private infrastructure
- internal endpoints or credentials
- customer information
- unreleased products
- confidential business logic
- internal metrics, unless public or approved
- specific security decisions
- anything else that should reasonably stay internal

Flag these for the user instead of silently removing them. When a company-specific claim matters, suggest checking whether it is public. Keep implementation examples generalized: rewrite internal code as a minimal example that shows the same idea.
