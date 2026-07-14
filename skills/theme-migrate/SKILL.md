---
name: theme-migrate
description: Recolor the terminal stack — Ghostty terminal cells (used by cmux) + starship prompt — to a named Ghostty theme, deterministically, using Ghostty's own theme files as the palette source.
when_to_use: Use when the user wants to change / migrate / switch their terminal theme, starship prompt colors, cmux/Ghostty colors, or says things like "make my terminal Catppuccin", "switch to Nord", "theme migrate to Tokyo Night", or invokes /theme-migrate.
trigger: /theme-migrate <Theme Name>
---

# theme-migrate

Migrate the whole terminal look to one **named Ghostty theme** in one shot. Two surfaces change together:

- **`~/.config/ghostty/config`** — the `theme = …` line → the actual terminal cell colors (cmux embeds Ghostty).
- **`~/.config/starship.toml`** — every hardcoded hex → remapped to the new theme.

No hardcoded palettes: the target theme's hexes come straight from Ghostty's ~400 shipped theme files. Starship colors are remapped by **ANSI-slot**, not by guessing — each hex in `starship.toml` is matched to its slot in the *current* theme, then replaced with the *target* theme's hex for that same slot. So it works no matter what theme you're on now.

## Usage

```
/theme-migrate <Theme Name>          # e.g. Catppuccin Mocha, Nord, Tokyo Night, Dracula+
```

## How to run it

The engine is `theme_migrate.py` in this skill's directory. It is deterministic — run it, don't hand-edit colors.

1. **Confirm the theme name** the user wants. If unsure or they ask what's available:
   ```
   python3 <skill-dir>/theme_migrate.py --list
   ```
2. **Preview** (recommended before writing):
   ```
   python3 <skill-dir>/theme_migrate.py "<Theme Name>" --dry-run
   ```
   Show the user the diff. If a theme name isn't found, the script suggests near matches — relay them.
3. **Apply**:
   ```
   python3 <skill-dir>/theme_migrate.py "<Theme Name>"
   ```
   Writes both files (backing each up to `*.bak` first) and prints a reload hint.
4. **Tell the user to reload**: cmux → `Reload Configuration` (`cmd+shift+,`) or a new Ghostty window for terminal cells; a fresh shell prompt picks up starship.

## Notes

- If the script reports hexes "left as-is", those are colors in `starship.toml` that don't correspond to any ANSI slot in the current theme (e.g. a custom accent). Leaving them is correct — surface the list to the user in case they want to handle those by hand.
- Out of scope: cmux chrome (workspace swatches, pane borders, sidebar tint), non-Ghostty terminals, light/dark auto-switch. Add later only if asked.
- Self-test: `python3 <skill-dir>/theme_migrate.py --check` (round-trips Gruvbox Dark → Catppuccin Mocha and asserts the slot mapping).
