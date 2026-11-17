#!/usr/bin/env bash
# Capture the Linux desktop for coding agents (Wayland/niri-first).
# Prints the absolute output path on success.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: capture.sh [mode] [args...] [output.png]

Modes:
  full|screen          Entire focused output (default)
  all                  All outputs
  window               Focused window (niri), else full screen
  output NAME [path]   Named Wayland output (e.g. eDP-1)
  region GEO [path]    Geometry "x,y WxH" (grim -g)
  list                 List outputs / focused window; no capture

Env:
  DESKTOP_SCREENSHOT_DIR  Default dir when output omitted
                          (default: /tmp/desktop-screenshots)
  DESKTOP_SCREENSHOT_NOTIFY  Set to 0 to skip the desktop notification
                          (default: on, via notify-send)
EOF
}

resolve_grim() {
  if command -v grim >/dev/null 2>&1; then
    GRIM=(grim)
    return
  fi
  if command -v nix >/dev/null 2>&1; then
    GRIM=(nix shell nixpkgs#grim -c grim)
    return
  fi
  echo "error: grim not found. Install grim (and slurp for interactive regions)." >&2
  echo "  NixOS/home-manager: add pkgs.grim pkgs.slurp to home.packages" >&2
  exit 1
}

default_out() {
  local dir="${DESKTOP_SCREENSHOT_DIR:-/tmp/desktop-screenshots}"
  mkdir -p "$dir"
  printf '%s/shot-%s.png' "$dir" "$(date +%Y%m%dT%H%M%S)"
}

abspath() {
  local p="$1"
  if [[ "$p" != /* ]]; then
    p="$(pwd)/$p"
  fi
  mkdir -p "$(dirname "$p")"
  printf '%s' "$p"
}

need_wayland() {
  if [[ -z "${WAYLAND_DISPLAY:-}" && "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
    echo "error: no Wayland session (WAYLAND_DISPLAY unset). Desktop capture needs a live graphical session." >&2
    exit 1
  fi
}

list_info() {
  echo "session: ${XDG_SESSION_TYPE:-unknown}  WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-}"
  echo "desktop: ${XDG_CURRENT_DESKTOP:-unknown}"
  if command -v niri >/dev/null 2>&1; then
    echo "--- niri outputs ---"
    niri msg outputs 2>/dev/null || true
    echo "--- niri focused window ---"
    niri msg focused-window 2>/dev/null || true
  elif command -v wlr-randr >/dev/null 2>&1; then
    wlr-randr
  else
    echo "(install niri or wlr-randr for richer listing)"
  fi
}

have_niri() { [[ -n "${NIRI_SOCKET:-}" ]] && command -v niri >/dev/null 2>&1; }

# niri's own screenshot, pointer hidden. Usage: niri_shot screen|window OUT
# niri writes the file asynchronously, so wait for it.
niri_shot() {
  local kind="$1" out="$2" i
  rm -f "$out"
  niri msg action "screenshot-$kind" --show-pointer false --path "$out" >/dev/null || return 1
  for i in $(seq 1 50); do
    [[ -s "$out" ]] && return 0
    sleep 0.1
  done
  return 1
}

finish() {
  local out="$1"
  if [[ ! -f "$out" ]]; then
    echo "error: capture produced no file at $out" >&2
    exit 2
  fi
  local abs
  abs="$(realpath "$out" 2>/dev/null || readlink -f "$out" 2>/dev/null || echo "$out")"
  # Sent after grim, so the popup never lands in this shot (it can in the next one).
  if [[ "${DESKTOP_SCREENSHOT_NOTIFY:-1}" != 0 ]] && command -v notify-send >/dev/null 2>&1; then
    notify-send -a Screenshot -i "$abs" 'Agent screenshot' "$abs" || true
  fi
  echo "$abs"
}

mode="${1:-full}"
shift || true

case "$mode" in
  -h|--help|help) usage; exit 0 ;;
  list) list_info; exit 0 ;;
esac

need_wayland
resolve_grim

case "$mode" in
  full|screen)
    out="$(abspath "${1:-$(default_out)}")"
    have_niri && niri_shot screen "$out" || "${GRIM[@]}" "$out"
    finish "$out"
    ;;
  all)
    out="$(abspath "${1:-$(default_out)}")"
    # niri only shoots the focused screen; use it when that is the whole desktop.
    if have_niri && [[ "$(niri msg -j outputs | jq length)" == 1 ]] && niri_shot screen "$out"; then
      :
    else
      "${GRIM[@]}" "$out"
    fi
    finish "$out"
    ;;
  window)
    out="$(abspath "${1:-$(default_out)}")"
    if have_niri && niri_shot window "$out"; then
      finish "$out"
    else
      echo "warn: window capture via niri failed; falling back to full screen" >&2
      "${GRIM[@]}" "$out"
      finish "$out"
    fi
    ;;
  output)
    name="${1:-}"
    if [[ -z "$name" ]]; then
      echo "error: output mode needs NAME" >&2
      usage >&2
      exit 1
    fi
    out="$(abspath "${2:-$(default_out)}")"
    "${GRIM[@]}" -o "$name" "$out"
    finish "$out"
    ;;
  region)
    geo="${1:-}"
    if [[ -z "$geo" ]]; then
      echo "error: region mode needs GEO like '100,100 800x600'" >&2
      exit 1
    fi
    out="$(abspath "${2:-$(default_out)}")"
    "${GRIM[@]}" -g "$geo" "$out"
    finish "$out"
    ;;
  *)
    # First arg was an output path → full capture there
    if [[ "$mode" == *.png || "$mode" == */* ]]; then
      out="$(abspath "$mode")"
      "${GRIM[@]}" "$out"
      finish "$out"
    else
      echo "error: unknown mode '$mode'" >&2
      usage >&2
      exit 1
    fi
    ;;
esac
