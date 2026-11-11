#!/usr/bin/env python3
"""Passive kanata mode overlay daemon.

Watches the kanata mode cache file and reports mode changes. The window and
service wiring arrive in later tasks; this module only decides when a flash is
warranted and polls the cache file.
"""

import os
import time

MODE_COLORS: dict[str, str] = {
    "BASE": "#FFFFFF",
    "INSERT": "#00FF00",
    "NORMAL": "#00BFFF",
    "VISUAL": "#FFFF00",
    "VISUAL-LINE": "#FF00FF",
    "MOUSE": "#FFC0CB",
}
KNOWN_MODES: set[str] = set(MODE_COLORS)
# Expanded at runtime so the daemon follows whichever user owns the session.
MODE_FILE: str = os.path.expanduser("~/.cache/kanata-mode")
POLL_MS: int = 50


def normalize_mode(raw: str) -> str:
    return raw.strip().upper()


def should_show(previous: str, current: str) -> bool:
    # Returning to BASE hides silently, and unchanged mode means no new flash.
    if not current or current == "BASE":
        return False
    return current != previous


def read_mode(path: str) -> str:
    # A deleted or unreadable cache is treated as BASE so the overlay hides
    # instead of the daemon crashing.
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return normalize_mode(handle.read())
    except (OSError, UnicodeDecodeError):
        return "BASE"


def watch(path: str, on_change: callable) -> None:
    previous = read_mode(path)
    last_signature = None
    while True:
        try:
            stat = os.stat(path)
            signature = (stat.st_mtime_ns, stat.st_size)
        except OSError:
            signature = None

        # Re-read only when the file changed on disk; a missing file has no
        # signature so a deletion is noticed exactly once.
        if signature != last_signature:
            last_signature = signature
            current = read_mode(path)
            if current != previous:
                on_change(previous, current)
                previous = current

        time.sleep(POLL_MS / 1000)
