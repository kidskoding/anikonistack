"""Poking the running app so color changes take effect immediately.

cmux needs an explicit reload for the embedded Ghostty palette/background — a
new shell reloads starship but NOT the terminal cell colors.
"""
import os
import shutil
import subprocess

CMUX_FALLBACK = "/Applications/cmux.app/Contents/Resources/bin/cmux"


def reload_cmux():
    cli = shutil.which("cmux") or CMUX_FALLBACK
    if os.path.exists(cli):
        try:
            r = subprocess.run([cli, "reload-config"], capture_output=True, text=True, timeout=10)
            print("cmux reload-config:", (r.stdout or r.stderr).strip() or f"exit {r.returncode}")
            return
        except Exception as e:
            print(f"cmux reload-config failed ({e}); reload manually: cmux cmd+shift+, or a new Ghostty window.")
            return
    print("reload terminal: cmux `Reload Configuration` (cmd+shift+,) or a new Ghostty window.")
