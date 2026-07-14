"""Runnable self-test: round-trip real theme files (Gruvbox Dark -> Catppuccin
Mocha) through the transforms and assert the slot mapping, truecolor escape,
and arrow recolor all land correctly. No filesystem writes.
"""
import sys

from palette import parse_theme, resolve_theme, theme_green
from recolor import migrate_text, set_arrow_green


def self_check():
    gru = parse_theme(resolve_theme("Gruvbox Dark"))
    mocha = parse_theme(resolve_theme("Catppuccin Mocha"))
    # starship uses these gruvbox accents + #282828 as on-segment text;
    # fastfetch also embeds a truecolor escape (38;2;251;73;52 == #fb4934).
    sample = "fg:#fb4934 bg:#fabd2f green #b8bb26 blue #83a598 #d3869b fg:#282828 bold white \033[38;2;251;73;52m"
    new, changed, unmatched = migrate_text(sample, gru, mocha)
    checks = {
        "#fb4934->slot9":  mocha["9"],   # bright red
        "#fabd2f->slot11": mocha["11"],  # bright yellow
        "#b8bb26->slot10": mocha["10"],  # bright green
        "#83a598->slot12": mocha["12"],  # bright blue
        "#d3869b->slot13": mocha["13"],  # bright magenta
        "#282828->bg":     mocha["background"],  # on-segment text -> bg
    }
    ok = True
    for label, want in checks.items():
        present = want in new
        ok = ok and present
        print(f"  [{'ok' if present else 'FAIL'}] {label}: expect {want} present -> {present}")

    assert "white" in new, "non-hex tokens must be preserved"
    # truecolor escape #fb4934 -> mocha #f37799 == rgb 243;119;153
    r, g, b = int(mocha["9"][1:3], 16), int(mocha["9"][3:5], 16), int(mocha["9"][5:7], 16)
    assert f"38;2;{r};{g};{b}" in new, f"truecolor escape not remapped: {new!r}"
    print(f"  [ok] 38;2;R;G;B escape -> {r};{g};{b}")
    assert changed == 7, f"expected 7 remaps (6 hex + 1 escape), got {changed}"
    assert unmatched == [], f"unexpected unmatched: {unmatched}"

    # arrow recolor: named green and a prior hex both -> theme green
    gh = theme_green(mocha)
    a1, n1 = set_arrow_green("[➜](bold green)", gh)
    a2, n2 = set_arrow_green("[➜](bold #31748f)", gh)
    assert n1 == 1 and n2 == 1 and f"bold {gh}" in a1 and f"bold {gh}" in a2, f"arrow recolor failed: {a1!r} {a2!r}"
    print(f"  [ok] arrow -> theme green {gh}")

    print("self-check:", "PASS" if ok else "FAIL")
    if not ok:
        sys.exit(1)
