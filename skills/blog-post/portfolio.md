# Portfolio Target

The user's portfolio: Astro + MDX + Tailwind v4, usually at `~/uiuc/go-mama-27/portfolio`. Its `CLAUDE.md` is the source of truth if anything here disagrees.

## Material for Stage 1

- `src/data/experience.ts`: companies, roles, dates, skills
- `src/data/education.ts`, `src/data/milestones.ts`: education and career milestones
- `src/content/projects/<slug>.mdx` or `<slug>/index.mdx`: project case studies with `repo`, `stack`, `event`, `placement`. Link related posts to `/projects/<slug>`.

## File

Path: `src/content/blog/<kebab-case-slug>.mdx`. Frontmatter must match `src/content.config.ts`:

```mdx
---
title: "<idea-driven title>"
description: "<subtitle; renders under the h1 and on the blog index>"
pubDate: <YYYY-MM-DD, today>
draft: true
coverImage: "/blog/<slug>-cover.<ext>"
---

import TweetEmbed from '../../components/TweetEmbed.astro';

[post body]
```

- `draft: true` while iterating. Drafts are excluded from the build, so to preview locally the user flips it to `false`. Remove it when publishing.
- `coverImage` (served from `public/blog/`) and the `TweetEmbed` import only when used. Tweets embed as `<TweetEmbed url="..." />`.
- News analysis posts end with a `## References` section and cite inline with `<sup>[N](#references)</sup>`.
- Add `*Originally published on [DEV](<url>).*` only for posts actually on DEV.

After writing or revising, run `bun run build` in the portfolio root and fix any MDX error before reporting back.

## Rendering

- `##` renders green, `###` yellow. Blockquotes, tables, and `---` rules are styled.
- `description` is the subtitle. Put the employer or job context there, not in the title.

## Gotchas

- **Frontmatter is `pubDate`, not `date`, and there is no `tags` or `subtitle` field.** Zod strips unknown keys silently.
- **MDX treats `<` and `{` in prose as JSX.** `Effect<A, E, R>` or `{id}` outside backticks breaks the build.
- **Numbered lists render without numbers** in `src/pages/blog/[...id].astro` (only `ul` is styled). Use headings or bullets for sequences.
- **Mermaid does not render** (only `@astrojs/mdx` is installed). Draw diagrams as ASCII in a ```` ```text ```` fence, or put an image in `public/blog/`.
- **Code blocks use Astro's default Shiki theme**, not gruvbox, and inline code has no styling.
