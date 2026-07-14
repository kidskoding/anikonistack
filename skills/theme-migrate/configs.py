"""Where the theme-bearing configs live, plus small filesystem helpers.

Adding a new app to the migration = add its path here and a target entry in
migrate.py. Everything else (parsing, remapping) is app-agnostic.
"""
import os

HOME = os.path.expanduser("~")
GHOSTTY_CONFIG = os.path.join(HOME, ".config/ghostty/config")
STARSHIP_CONFIG = os.environ.get("STARSHIP_CONFIG", os.path.join(HOME, ".config/starship.toml"))
FASTFETCH_CONFIG = os.path.join(HOME, ".config/fastfetch/config.jsonc")


def current_ghostty_theme():
    """The active `theme = X` value in the ghostty config, or None."""
    if not os.path.isfile(GHOSTTY_CONFIG):
        return None
    with open(GHOSTTY_CONFIG) as f:
        for line in f:
            s = line.strip()
            if s.startswith("theme") and "=" in s and not s.startswith("#"):
                return s.split("=", 1)[1].strip()
    return None


def backup(path):
    """Copy path -> path.bak before overwriting."""
    with open(path) as f:
        data = f.read()
    with open(path + ".bak", "w") as f:
        f.write(data)
