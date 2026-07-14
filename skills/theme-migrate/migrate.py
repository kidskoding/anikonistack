"""Orchestration: read the source + target palettes, rewrite every config,
write (or preview) the changes, then reload cmux.

Ties together palette (read themes), recolor (transform text), configs (paths),
and reload (apply). The per-app list below is the whole surface area.
"""
import os
import difflib

from palette import resolve_theme, parse_theme, theme_green
from recolor import migrate_text, set_arrow_green, set_ghostty_theme
from configs import (
    GHOSTTY_CONFIG, STARSHIP_CONFIG, FASTFETCH_CONFIG,
    current_ghostty_theme, backup,
)
from reload import reload_cmux

# color-bearing configs remapped by slot. (label, path)
COLOR_TARGETS = [
    ("starship", STARSHIP_CONFIG),
    ("fastfetch", FASTFETCH_CONFIG),
]


def run(target_name, dry_run=False, from_name=None, arrow=None):
    tgt_path = resolve_theme(target_name)
    tgt_name = os.path.basename(tgt_path)
    tgt_theme = parse_theme(tgt_path)

    # source palette: --from override (use when configs are out of sync with the
    # ghostty theme line), else the current ghostty theme.
    cur_name = from_name or current_ghostty_theme()
    if not cur_name:
        raise SystemExit(f"error: no `theme = ` line in {GHOSTTY_CONFIG}; set one first, or pass --from <Theme>.")
    cur_theme = parse_theme(resolve_theme(cur_name))

    print(f"migrating: {cur_name}  ->  {tgt_name}")

    # ghostty config: just the theme line
    with open(GHOSTTY_CONFIG) as f:
        gtext = f.read()
    pending = [(GHOSTTY_CONFIG, gtext, set_ghostty_theme(gtext, tgt_name))]  # (path, old, new)

    for label, path in COLOR_TARGETS:
        if not os.path.isfile(path):
            print(f"{label}: {path} not found, skipping")
            continue
        with open(path) as f:
            old = f.read()
        new, changed, unmatched = migrate_text(old, cur_theme, tgt_theme)
        if path == STARSHIP_CONFIG:
            # --arrow overrides the theme green (e.g. themes with no true green).
            new, arrow_n = set_arrow_green(new, arrow or theme_green(tgt_theme))
            changed += arrow_n
        note = f", {len(unmatched)} color(s) left as-is (no ANSI slot): {unmatched}" if unmatched else ""
        print(f"{label}: {changed} color(s) remapped{note}")
        pending.append((path, old, new))

    if dry_run:
        for path, old, new in pending:
            print(f"\n--- {path} (dry-run) ---")
            for l in difflib.unified_diff(old.splitlines(), new.splitlines(), lineterm="", n=0):
                if l.startswith(("+", "-")) and not l.startswith(("+++", "---")):
                    print(l)
        print("\n(dry-run, nothing written)")
        return

    for path, old, new in pending:
        if new != old:
            backup(path)
            with open(path, "w") as f:
                f.write(new)

    print("done. backups written to *.bak")
    reload_cmux()
    print("open a new shell prompt (or tab) to pick up starship + fastfetch colors.")
