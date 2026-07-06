# anikonistack

My reproducible Claude Code stack — skills, status line, and hooks. Clone on any machine, run `setup.sh`, get the same setup.

## What's in it

```
anikonistack/
├── skills/     # graphify, eli5, update-claude-md, commit
├── hooks/      # statusline.sh (enabled-plugin badges)
└── setup.sh    # symlinks everything into ~/.claude
```

## Install

```bash
git clone https://github.com/kidskoding/anikonistack.git
cd anikonistack
./setup.sh
```

`setup.sh` symlinks the skills and hooks into `~/.claude/`. It does **not**
touch your `~/.claude/settings.json` — configure model, status line, and
permissions there yourself.

To use `statusline.sh`, point your `settings.json` at it:

```json
"statusLine": { "type": "command", "command": "bash \"$HOME/.claude/hooks/statusline.sh\"" }
```

## Plugins

Install these separately (they self-wire their own hooks/skills):

```
/plugin marketplace add JuliusBrussee/caveman   && /plugin install caveman@caveman
/plugin marketplace add DietrichGebert/ponytail && /plugin install ponytail@ponytail
/plugin marketplace add bokuhe/claude-duet      && /plugin install duet@duet-marketplace
/plugin install superpowers@claude-plugins-official
```

- [superpowers](https://github.com/anthropics/claude-plugins) — skill framework
- [caveman](https://github.com/JuliusBrussee/caveman) — terse output mode
- [ponytail](https://github.com/DietrichGebert/ponytail) — laziest-solution mode
- [duet](https://github.com/bokuhe/claude-duet) — Gemini-assisted review/PR
