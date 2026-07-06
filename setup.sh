#!/usr/bin/env bash
# konistack installer — symlinks skills/commands/hooks into ~/.claude and
# installs settings.json (backing up any existing one).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing konistack into $CLAUDE_DIR"
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

# settings.json — back up existing, then copy (not symlink, so you can tweak locally)
if [ -f "$CLAUDE_DIR/settings.json" ] && [ ! -L "$CLAUDE_DIR/settings.json" ]; then
  cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.pre-konistack.bak"
  echo "  backed up existing settings.json -> settings.json.pre-konistack.bak"
fi
cp "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
echo "  installed settings.json"

echo
echo "Done. Restart Claude Code. Plugins (superpowers, caveman, ponytail, duet)"
echo "auto-install from their marketplaces on next launch."
