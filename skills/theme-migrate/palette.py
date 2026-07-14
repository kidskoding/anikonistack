"""Reading Ghostty theme files: discover the themes dir, resolve a name, parse a
theme into a {slot -> hex} palette, and build the reverse map for remapping.

This module knows nothing about starship/fastfetch — it only reads palettes.
"""
import os
import re
import difflib

HOME = os.path.expanduser("~")
HEX = re.compile(r"#[0-9a-fA-F]{6}")
THEME_DIRS = [
    "/Applications/cmux.app/Contents/Resources/ghostty/themes",
    "/Applications/Ghostty.app/Contents/Resources/ghostty/themes",
    os.path.join(HOME, ".config/ghostty/themes"),
]


def themes_dir():
    for d in THEME_DIRS:
        if os.path.isdir(d):
            return d
    raise SystemExit("error: no Ghostty themes directory found. Looked in:\n  " + "\n  ".join(THEME_DIRS))


def list_themes():
    return sorted(os.listdir(themes_dir()))


def resolve_theme(name):
    """Path for a theme name: exact, else case-insensitive, else suggest."""
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
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, val = line.partition("=")
            key, val = key.strip(), val.strip()
            m = HEX.search(val)
            if not m:
                continue
            hexv = m.group(0).lower()
            if key == "palette":
                # "palette = 9=#fb4934" -> val is "9=#fb4934"
                out[val.split("=", 1)[0].strip()] = hexv
            else:
                out[key] = hexv
    return out


def reverse_map(theme):
    """hex -> slot. Semantic keys override numeric slots on collision
    (e.g. gruvbox slot 0 == background == #282828; prefer 'background')."""
    rev = {}
    for k, v in theme.items():
        if k.isdigit():
            rev[v] = k
    for k in ("foreground", "background", "cursor-color", "selection-background"):
        if k in theme:
            rev[theme[k]] = k  # semantic wins
    return rev


def theme_green(theme):
    """The theme's green ANSI slot (bright 10, else normal 2). Note: some
    themes map 'green' to a teal (e.g. Rose Pine pine #31748f)."""
    return theme.get("10") or theme.get("2")
