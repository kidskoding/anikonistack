---
name: desktop-screenshot
description: >-
  Capture screenshots of the user's real Linux desktop (any app, not just
  browsers) via Wayland tools. Use when the user asks to screenshot the
  screen, desktop, window, monitor, UI outside the browser, "what do you
  see", or to look at something on their system. Prefer Playwright /
  browser screenshot tools for web pages only.
compatibility: >-
  Linux Wayland (niri / wlroots). Requires grim; slurp optional for
  interactive regions. Falls back to `nix shell nixpkgs#grim` if grim
  is not on PATH.
---

# Desktop screenshot

Take a real screenshot of the user's **system desktop** so you can see
what is on screen (native apps, terminals, editors, games, etc.).

This is **not** browser-page capture. For web UIs use Playwright /
`browser_take_screenshot` instead.

## When to use

- "Take a screenshot", "screenshot my screen/desktop/window"
- "What does my screen look like?", "look at my desktop"
- Debugging native UI, compositor layout, terminal apps, IDE chrome
- Capturing anything outside a browser tab

## When not to use

- Web page / localhost app → Playwright or browser MCP
- macOS / Windows computer-use tools (this skill is Linux Wayland)
- Headless SSH with no Wayland session (capture will fail; say so)

## Capture (required flow)

1. Run the capture script (prints absolute path of the PNG).
2. **Read the image file** with the Read tool so you can actually see it.
3. Answer from what you see. Do not claim screen contents without reading.

### Script path

Resolve the skill directory from wherever it is installed, then run `scripts/capture.sh`:

```bash
SKILL_DIR="$(find -L "$HOME/.cursor/skills" "$HOME/.claude/skills" \
  "$HOME/.codex/skills" -type d -name desktop-screenshot 2>/dev/null | head -1)"
bash "$SKILL_DIR/scripts/capture.sh" full
bash "$SKILL_DIR/scripts/capture.sh" window
bash "$SKILL_DIR/scripts/capture.sh" output eDP-1
bash "$SKILL_DIR/scripts/capture.sh" region "100,100 800x600"
bash "$SKILL_DIR/scripts/capture.sh" list
```

Default output: `/tmp/desktop-screenshots/shot-<timestamp>.png`

### Modes

| Mode | What it captures |
|------|------------------|
| `full` / `screen` (default) | Focused monitor (niri) or primary output |
| `all` | All monitors |
| `window` | Focused window via niri; falls back to full |
| `output NAME` | Named output (`eDP-1`, …) |
| `region "x,y WxH"` | Fixed rectangle |
| `list` | Session + outputs + focused window (no file) |

### One-liners if the script is unavailable

```bash
# Full / focused output
grim /tmp/agent-screen.png

# Named output
grim -o eDP-1 /tmp/agent-screen.png

# Region
grim -g "100,100 800x600" /tmp/agent-region.png

# Focused window (niri → ~/Pictures/Screenshots/)
niri msg action screenshot-window
```

If `grim` is missing but Nix is available:

```bash
nix shell nixpkgs#grim -c grim /tmp/agent-screen.png
```

## After capture

1. Confirm the printed path exists.
2. `Read` the PNG (agents can view images this way).
3. Describe only what is visible; call out uncertainty (occlusion, blur).
4. Offer another shot (`window`, other `output`, region) if needed.

## Environment notes (this machine)

- Session: Wayland + **niri**
- Screenshot dir (niri UI): `~/Pictures/Screenshots/`
- Agent captures: prefer `/tmp/desktop-screenshots/` (explicit path)
- Interactive region select needs `slurp`: `grim -g "$(slurp)" out.png`
  (agents should prefer numeric `region` so capture is non-blocking)

## Failure modes

| Symptom | What to tell the user |
|---------|----------------------|
| `WAYLAND_DISPLAY` unset | No graphical session in this shell; run from a desktop terminal / agent with Wayland env |
| `grim` missing | Install `grim` (+ `slurp`); on NixOS add to `home.packages` |
| Permission / black frame | Compositor blocked screencopy; check niri/portal permissions |
| Window mode timed out | Fall back to `full` or `output` |

## Privacy

Screenshots can include secrets (notifications, password managers, private chats). Prefer `window` or a tight `region` when the user only needs one app. Do not upload captures unless the user asks.
