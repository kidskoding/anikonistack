#!/usr/bin/env python3
"""theme-migrate: recolor the terminal stack (Ghostty cells + starship prompt)
to a named Ghostty theme, using Ghostty's own theme files as the palette source.

Mapping is deterministic — no hardcoded palettes:
  1. Read the CURRENT theme from the ghostty config, parse its theme file into
     {slot -> hex} (slots "0".."15", "background", "foreground", ...).
  2. Build the reverse hex -> slot map. Semantic keys (background/foreground)
     win collisions with numeric slots (e.g. gruvbox slot 0 == background).
  3. For every hex in starship.toml, find its slot in the current theme and
     substitute the TARGET theme's hex for that same slot. Unmatched hexes
     (e.g. plain 'white') are left untouched.
  4. Rewrite `theme = <Target>` in the ghostty config.

Usage:
  theme_migrate.py "<Theme Name>"     # migrate ghostty + starship
  theme_migrate.py "<Theme Name>" --dry-run
  theme_migrate.py --list             # list available theme names
  theme_migrate.py --check            # self-test, no writes
"""
import os
import re
import sys
import shutil
import difflib
import subprocess

HOME = os.path.expanduser("~")
GHOSTTY_CONFIG = os.path.join(HOME, ".config/ghostty/config")
STARSHIP_CONFIG = os.environ.get("STARSHIP_CONFIG", os.path.join(HOME, ".config/starship.toml"))
FASTFETCH_CONFIG = os.path.join(HOME, ".config/fastfetch/config.jsonc")
THEME_DIRS = [
    "/Applications/cmux.app/Contents/Resources/ghostty/themes",
    "/Applications/Ghostty.app/Contents/Resources/ghostty/themes",
    os.path.join(HOME, ".config/ghostty/themes"),
]
HEX = re.compile(r"#[0-9a-fA-F]{6}")
# truecolor SGR escape params: 38;2;R;G;B (fg) or 48;2;R;G;B (bg), e.g. in
# fastfetch's embedded ANSI (\033[38;2;251;73;52m). Matched regardless of how
# the escape byte is spelled (\033, , \x1b) since we only touch the digits.
TRUECOLOR = re.compile(r"(38|48);2;(\d{1,3});(\d{1,3});(\d{1,3})")


def themes_dir():
    for d in THEME_DIRS:
        if os.path.isdir(d):
            return d
    raise SystemExit("error: no Ghostty themes directory found. Looked in:\n  " + "\n  ".join(THEME_DIRS))


def list_themes():
    return sorted(os.listdir(themes_dir()))


def resolve_theme(name):
    """Exact match, else case-insensitive, else suggest near matches."""
    d = themes_dir()
    path = os.path.join(d, name)
    if os.path.isfile(path):
        return path
    names = list_themes()
    for n in names:
        if n.lower() == name.lower():
            return os.path.join(d, n)
    near = difflib.get_close_matches(name, names, n=6, cutoff=0.4)
    hint = ("\n  did you mean: " + ", ".join(near)) if near else ""
    raise SystemExit(f'error: theme "{name}" not found in {d}{hint}\n  run with --list to see all.')


def parse_theme(path):
    """Ghostty theme file -> {slot: '#rrggbb'} with slots '0'..'15' and
    'background'/'foreground'/'cursor-color'/... Hex normalized lowercase."""
    out = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" not in line:
                continue
            key, _, val = line.partition("=")
            key, val = key.strip(), val.strip()
            m = HEX.search(val)
            if not m:
                continue
            hexv = m.group(0).lower()
            if key == "palette":
                # "palette = 9=#fb4934" -> val is "9=#fb4934"
                slot = val.split("=", 1)[0].strip()
                out[slot] = hexv
            else:
                out[key] = hexv
    return out


def reverse_map(theme):
    """hex -> slot. Semantic keys override numeric slots on collision."""
    rev = {}
    for k, v in theme.items():
        if k.isdigit():
            rev[v] = k
    for k in ("foreground", "background", "cursor-color", "selection-background"):
        if k in theme:
            rev[theme[k]] = k  # semantic wins
    return rev


def migrate_text(text, cur_theme, tgt_theme):
    """Remap both #rrggbb hexes and truecolor `38;2;R;G;B` escapes by ANSI slot.
    Return (new_text, changed, sorted_unmatched)."""
    rev = reverse_map(cur_theme)
    unmatched = set()
    changed = 0

    def lookup(h):
        """current hex -> target hex, or None if the slot can't be mapped."""
        slot = rev.get(h)
        if slot is None:
            unmatched.add(h)
            return None
        newhex = tgt_theme.get(slot)
        if newhex is None:
            unmatched.add(h)
            return None
        return newhex

    def hex_sub(m):
        nonlocal changed
        h = m.group(0).lower()
        newhex = lookup(h)
        if newhex is None:
            return m.group(0)
        if newhex != h:
            changed += 1
        return newhex

    def rgb_sub(m):
        nonlocal changed
        prefix = m.group(1)
        r, g, b = int(m.group(2)), int(m.group(3)), int(m.group(4))
        h = "#%02x%02x%02x" % (r, g, b)
        newhex = lookup(h)
        if newhex is None:
            return m.group(0)
        nr, ng, nb = int(newhex[1:3], 16), int(newhex[3:5], 16), int(newhex[5:7], 16)
        if newhex != h:
            changed += 1
        return f"{prefix};2;{nr};{ng};{nb}"

    text = HEX.sub(hex_sub, text)
    text = TRUECOLOR.sub(rgb_sub, text)
    return text, changed, sorted(unmatched)


def current_ghostty_theme():
    if not os.path.isfile(GHOSTTY_CONFIG):
        return None
    with open(GHOSTTY_CONFIG) as f:
        for line in f:
            s = line.strip()
            if s.startswith("theme") and "=" in s and not s.startswith("#"):
                return s.split("=", 1)[1].strip()
    return None


def set_ghostty_theme(text, name):
    # ponytail: single-theme `theme = X` form only. If a user runs the
    # `theme = dark:A,light:B` split form, add split handling then.
    if re.search(r"(?m)^\s*theme\s*=", text):
        return re.sub(r"(?m)^(\s*theme\s*=).*$", rf"\1 {name}", text)
    return text.rstrip("\n") + f"\ntheme = {name}\n"


def backup(path):
    with open(path) as f:
        data = f.read()
    with open(path + ".bak", "w") as f:
        f.write(data)


def run(target_name, dry_run=False, from_name=None):
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
    new_gtext = set_ghostty_theme(gtext, tgt_name)
    pending = [(GHOSTTY_CONFIG, gtext, new_gtext)]  # (path, old, new)

    # color-bearing configs: remap every hex + truecolor escape by slot
    for label, path in (("starship", STARSHIP_CONFIG), ("fastfetch", FASTFETCH_CONFIG)):
        if not os.path.isfile(path):
            print(f"{label}: {path} not found, skipping")
            continue
        with open(path) as f:
            old = f.read()
        new, changed, unmatched = migrate_text(old, cur_theme, tgt_theme)
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


def reload_cmux():
    """cmux needs an explicit reload for the embedded Ghostty palette/background.
    A new shell reloads starship but NOT the terminal cell colors."""
    cli = shutil.which("cmux") or "/Applications/cmux.app/Contents/Resources/bin/cmux"
    if os.path.exists(cli):
        try:
            r = subprocess.run([cli, "reload-config"], capture_output=True, text=True, timeout=10)
            print("cmux reload-config:", (r.stdout or r.stderr).strip() or f"exit {r.returncode}")
            return
        except Exception as e:
            print(f"cmux reload-config failed ({e}); reload manually: cmux cmd+shift+, or a new Ghostty window.")
            return
    print("reload terminal: cmux `Reload Configuration` (cmd+shift+,) or a new Ghostty window.")


def self_check():
    """Round-trip against real theme files: Gruvbox Dark -> Catppuccin Mocha."""
    d = themes_dir()
    gru = parse_theme(resolve_theme("Gruvbox Dark"))
    mocha = parse_theme(resolve_theme("Catppuccin Mocha"))
    # starship uses these gruvbox accents + #282828 as on-segment text;
    # fastfetch also embeds a truecolor escape (38;2;251;73;52 == #fb4934).
    sample = "fg:#fb4934 bg:#fabd2f green #b8bb26 blue #83a598 #d3869b fg:#282828 bold white \033[38;2;251;73;52m"
    new, changed, unmatched = migrate_text(sample, gru, mocha)
    checks = {
        "#fb4934->slot9":  ("#fb4934", mocha["9"]),   # bright red
        "#fabd2f->slot11": ("#fabd2f", mocha["11"]),  # bright yellow
        "#b8bb26->slot10": ("#b8bb26", mocha["10"]),  # bright green
        "#83a598->slot12": ("#83a598", mocha["12"]),  # bright blue
        "#d3869b->slot13": ("#d3869b", mocha["13"]),  # bright magenta
        "#282828->bg":     ("#282828", mocha["background"]),  # on-segment text -> bg
    }
    ok = True
    for label, (src, want) in checks.items():
        got = want if want in new else None
        present = want in new
        status = "ok" if present else "FAIL"
        if not present:
            ok = False
        print(f"  [{status}] {label}: expect {want} present -> {present}")
    assert "white" in new, "non-hex tokens must be preserved"
    # truecolor escape #fb4934 -> mocha #f37799 == rgb 243;119;153
    r, g, b = int(mocha["9"][1:3], 16), int(mocha["9"][3:5], 16), int(mocha["9"][5:7], 16)
    assert f"38;2;{r};{g};{b}" in new, f"truecolor escape not remapped: {new!r}"
    print(f"  [{'ok' if f'38;2;{r};{g};{b}' in new else 'FAIL'}] 38;2;R;G;B escape -> {r};{g};{b}")
    assert changed == 7, f"expected 7 remaps (6 hex + 1 escape), got {changed}"
    assert unmatched == [], f"unexpected unmatched: {unmatched}"
    print("self-check:", "PASS" if ok else "FAIL")
    if not ok:
        sys.exit(1)


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
