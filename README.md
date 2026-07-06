# anikonistack

My reproducible Claude Code stack — skills, status line, hooks, and settings. Clone on any machine, run `setup.sh`, get the same setup.

## What's in it

```
anikonistack/
├── skills/        # graphify, eli5, update-claude-md, commit
├── hooks/         # statusline.sh (enabled-plugin badges)
├── settings.json  # model, permissions, status line, hooks, plugins
└── setup.sh       # symlinks everything into ~/.claude
```

## Install

```bash
git clone https://github.com/kidskoding/anikonistack.git
cd anikonistack
./setup.sh
```

Restart Claude Code. `setup.sh` symlinks the skills/commands/hooks into
`~/.claude/` and copies in `settings.json` (your existing one is backed up to
`settings.json.pre-anikonistack.bak`).

## Plugins

The stack doesn't vendor plugins — `settings.json` lists them as GitHub
marketplaces, so Claude Code auto-installs them on next launch:

- [superpowers](https://github.com/anthropics/claude-plugins) — skill framework
- [caveman](https://github.com/JuliusBrussee/caveman) — terse output mode
- [ponytail](https://github.com/DietrichGebert/ponytail) — laziest-solution mode
- [duet](https://github.com/bokuhe/claude-duet) — Gemini-assisted review/PR

## Notes

- Hook and status-line paths use `$HOME`, so they work under any username.
- The Discord-status hook from my personal setup is intentionally omitted
  (it pointed at a machine-specific `npx` cache path).
