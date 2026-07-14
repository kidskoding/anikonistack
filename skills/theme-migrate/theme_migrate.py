#!/usr/bin/env python3
"""theme-migrate: recolor the terminal stack (Ghostty cells + starship prompt +
fastfetch) to a named Ghostty theme, using Ghostty's own theme files as the
palette source. Mapping is deterministic — no hardcoded palettes.

Modules (by purpose):
  palette.py    read Ghostty theme files -> {slot: hex} + reverse map
  recolor.py    pure text transforms: hex/truecolor remap, arrow, ghostty line
  configs.py    config paths + backup + current-theme lookup
  migrate.py    orchestration: read palettes, rewrite configs, reload
  reload.py     cmux reload-config
  selfcheck.py  runnable round-trip test

Usage:
  theme_migrate.py "<Theme Name>"              migrate ghostty + starship + fastfetch
  theme_migrate.py "<Theme Name>" --dry-run    preview diffs, write nothing
  theme_migrate.py "<Theme>" --from "<Theme>"  override source palette (out-of-sync configs)
  theme_migrate.py --list                      list available theme names
  theme_migrate.py --check                     self-test, no writes
"""
import sys

from palette import list_themes
from migrate import run
from selfcheck import self_check


def main():
    args = sys.argv[1:]
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        return
    if args[0] == "--list":
        print("\n".join(list_themes()))
        return
    if args[0] == "--check":
        self_check()
        return

    dry = "--dry-run" in args
    from_name = None
    if "--from" in args:
        i = args.index("--from")
        if i + 1 >= len(args):
            raise SystemExit("error: --from needs a theme name.")
        from_name = args[i + 1]
    positional = [a for a in args if not a.startswith("-") and a != from_name]
    name = positional[0] if positional else None
    if not name:
        raise SystemExit("error: give a theme name. --list to see options.")
    run(name, dry_run=dry, from_name=from_name)


if __name__ == "__main__":
    main()
