# theme-migrate — design

**Goal:** one command recolors the terminal stack to a named Ghostty theme.

**Surfaces:**
- `~/.config/ghostty/config` → `theme = <Name>` (terminal cells; cmux embeds Ghostty).
- `~/.config/starship.toml` → every hex remapped.

**Palette source:** Ghostty's shipped theme files (`.../Resources/ghostty/themes/<Name>`), format `palette = N=#hex`, `background = #hex`, etc. ~400 themes, zero maintenance.

**Starship remap — slot mapping (deterministic):**
1. Read current `theme =` from ghostty config → parse that theme file → `{slot: hex}`.
2. Reverse to `hex -> slot`; semantic keys (`background`/`foreground`) win collisions with numeric slots (gruvbox slot 0 == background == `#282828`; on-segment text should follow `background`).
3. For each hex in `starship.toml`, look up its slot in the current theme, substitute the target theme's hex for that slot. Non-hex tokens and unmatched hexes left untouched (reported).
4. Rewrite ghostty `theme =`.

**Rejected:** hardcoding popular palettes (redundant with Ghostty, goes stale); LLM eyeballing colors (non-deterministic).

**Safety:** `.bak` written before each file; `--dry-run` shows diffs without writing; unknown theme name → near-match suggestions.

**Out of scope:** cmux chrome (workspace swatches, pane borders, sidebar tint), non-Ghostty terminals, light/dark split-theme form.

**Verify:** `theme_migrate.py --check` round-trips Gruvbox Dark → Catppuccin Mocha, asserts slot 9/10/11/12/13 + background land on Mocha's hexes and non-hex tokens survive.

**Install:** lives in `anikonistack/skills/theme-migrate/`; `setup.sh` symlinks it into `~/.claude/skills/`.
