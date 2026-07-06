#!/bin/bash
# Statusline: enabled-plugins list (color-coded)

BADGES=()

# --- Caveman badge ---
if [ -f "$HOME/.claude/.caveman-active" ]; then
  BADGES+=("$(printf '\033[38;5;172mcaveman\033[0m')")
fi

# --- Ponytail badge ---
if [ -f "$HOME/.claude/.ponytail-active" ]; then
  BADGES+=("$(printf '\033[38;5;205mponytail\033[0m')")
fi

# --- Output: "plugins enabled: a, b" ---
if [ ${#BADGES[@]} -gt 0 ]; then
  LABEL=$(printf '\033[38;5;245mplugins enabled:\033[0m')
  printf '%s %s' "$LABEL" "$(IFS=,; echo "${BADGES[*]}" | sed 's/,/, /g')"
fi
