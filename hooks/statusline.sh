#!/bin/bash
# Statusline: model name + enabled-plugins list (color-coded)

INPUT=$(cat)
MODEL=$(printf '%s' "$INPUT" | jq -r '.model.display_name // empty' 2>/dev/null)

BADGES=()

# --- Caveman badge ---
if [ -f "$HOME/.claude/.caveman-active" ]; then
  BADGES+=("$(printf '\033[38;5;172mcaveman\033[0m')")
fi

# --- Ponytail badge ---
if [ -f "$HOME/.claude/.ponytail-active" ]; then
  BADGES+=("$(printf '\033[38;5;205mponytail\033[0m')")
fi

# --- Output: "model | plugins enabled: a, b" ---
OUT=""
[ -n "$MODEL" ] && OUT="$(printf '\033[38;5;39m%s\033[0m' "$MODEL")"

if [ ${#BADGES[@]} -gt 0 ]; then
  LABEL=$(printf '\033[38;5;245mplugins enabled:\033[0m')
  BADGE_STR="$LABEL $(IFS=,; echo "${BADGES[*]}" | sed 's/,/, /g')"
  [ -n "$OUT" ] && OUT="$OUT $(printf '\033[38;5;240m|\033[0m') $BADGE_STR" || OUT="$BADGE_STR"
fi

printf '%s' "$OUT"
