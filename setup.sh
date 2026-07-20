#!/usr/bin/env bash
# anikonistack installer: symlinks skills/commands/hooks into ~/.claude and
# installs settings.json (backing up any existing one).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing anikonistack into $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR"/{skills,commands,hooks}

link() {  # link <src> <dst>
  ln -sfn "$1" "$2"
  echo "  linked $(basename "$2")"
}

# skills (one symlink per skill directory)
for dir in "$REPO_DIR"/skills/*/; do
  [ -d "$dir" ] || continue
  link "${dir%/}" "$CLAUDE_DIR/skills/$(basename "$dir")"
done

# slash commands
for f in "$REPO_DIR"/commands/*; do
  [ -f "$f" ] || continue
  link "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
done

# hooks (statusline + caveman)
for f in "$REPO_DIR"/hooks/*; do
  [ -f "$f" ] || continue
  link "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
done

echo
echo "done. restart Claude Code."
echo "your ~/.claude/settings.json is left untouched — add plugins yourself with:"
echo "  /plugin marketplace add JuliusBrussee/caveman  &&  /plugin install caveman@caveman"
echo "  /plugin marketplace add DietrichGebert/ponytail &&  /plugin install ponytail@ponytail"
