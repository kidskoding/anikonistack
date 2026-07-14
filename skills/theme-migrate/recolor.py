"""Pure color-text transforms. Given a current and target palette, rewrite the
colors embedded in a config's text — nothing here touches the filesystem.

- migrate_text: remap #rrggbb hexes AND truecolor `38;2;R;G;B` escapes by slot.
- set_arrow_green: recolor the starship success arrow to the theme green.
- set_ghostty_theme: rewrite the `theme = X` line in a ghostty config.
"""
import re

from palette import HEX, reverse_map

# truecolor SGR escape params: 38;2;R;G;B (fg) or 48;2;R;G;B (bg), e.g. in
# fastfetch's embedded ANSI (\033[38;2;251;73;52m). Matched regardless of how
# the escape byte is spelled (\033, , \x1b) since we only touch the digits.
TRUECOLOR = re.compile(r"(38|48);2;(\d{1,3});(\d{1,3});(\d{1,3})")
ARROW = re.compile(r"(➜\]\(bold\s+)(green|#[0-9a-fA-F]{6})(\))")


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


def set_arrow_green(text, green_hex):
    """Recolor the starship success arrow to the theme green. Idempotent:
    matches the named 'green' or a prior #hex. Return (new_text, count)."""
    if not green_hex:
        return text, 0
    return ARROW.subn(rf"\g<1>{green_hex}\g<3>", text)


def set_ghostty_theme(text, name):
    # ponytail: single-theme `theme = X` form only. If a user runs the
    # `theme = dark:A,light:B` split form, add split handling then.
    if re.search(r"(?m)^\s*theme\s*=", text):
        return re.sub(r"(?m)^(\s*theme\s*=).*$", rf"\1 {name}", text)
    return text.rstrip("\n") + f"\ntheme = {name}\n"
