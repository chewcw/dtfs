#!/usr/bin/env python3
"""Passive kanata mode overlay daemon.

Watches the kanata mode cache file and flashes a fading center label on mode
changes, staying silent when the target mode is BASE.
"""

import ctypes
import ctypes.util
import os
import sys
import time

try:
    import tkinter as tk
except ImportError:  # A missing Tk must not break the service on minimal installs.
    tk = None

MODE_COLORS: dict[str, str] = {
    "BASE": "#FFFFFF",
    "INSERT": "#00FF00",
    "NORMAL": "#00BFFF",
    "VISUAL": "#FFFF00",
    "VISUAL-LINE": "#FF00FF",
    "MOUSE": "#FFC0CB",
}
GLYPHS: dict[str, str] = {
    "INSERT": "I",
    "NORMAL": "N",
    "VISUAL": "V",
    "VISUAL-LINE": "V-LINE",
    "MOUSE": "MOUSE",
}
KNOWN_MODES: set[str] = set(MODE_COLORS)
# Expanded at runtime so the daemon follows whichever user owns the session.
MODE_FILE: str = os.path.expanduser("~/.cache/kanata-mode")
POLL_MS: int = 50

WINDOW_WIDTH: int = 480
WINDOW_HEIGHT: int = 160
FADE_MS: int = 700
FADE_STEP_MS: int = 30
FADE_STEPS: int = max(1, FADE_MS // FADE_STEP_MS)


def font_size_for(text: str, width: int, height: int) -> int:
    # The flash is a filled box, so the label budget stops at 90 percent of
    # the width and 50 percent of the height to clear the edges. Bold sans
    # advance is estimated at 0.6 of the point size, the factor the previous
    # fixed 40pt layout already assumed.
    if not text:
        return 12
    width_bound = (width * 0.9) / (len(text) * 0.6)
    height_bound = height * 0.5
    return max(12, int(min(width_bound, height_bound)))


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


class _InputShape:
    """Clear the X11 input shapes of a window tree so clicks fall through.

    Tk wraps an override-redirect Toplevel in an outer window and gives the
    Toplevel a child canvas window. An empty input shape is per-window, so the
    wrapper, the Toplevel, and every descendant all have to be shaped or the
    pointer still lands on one of them.
    """

    SHAPE_INPUT = 2
    SHAPE_SET = 0
    UNSORTED = 0

    def __init__(self) -> None:
        self.display = None
        self.x11 = None
        self.xext = None
        self.root = 0
        try:
            x11_name = ctypes.util.find_library("X11")
            xext_name = ctypes.util.find_library("Xext")
            if not (x11_name and xext_name):
                return
            x11 = ctypes.CDLL(x11_name)
            xext = ctypes.CDLL(xext_name)
            x11.XOpenDisplay.restype = ctypes.c_void_p
            x11.XOpenDisplay.argtypes = [ctypes.c_char_p]
            x11.XDefaultRootWindow.restype = ctypes.c_ulong
            x11.XDefaultRootWindow.argtypes = [ctypes.c_void_p]
            x11.XQueryTree.argtypes = [
                ctypes.c_void_p,
                ctypes.c_ulong,
                ctypes.POINTER(ctypes.c_ulong),
                ctypes.POINTER(ctypes.c_ulong),
                ctypes.POINTER(ctypes.POINTER(ctypes.c_ulong)),
                ctypes.POINTER(ctypes.c_uint),
            ]
            x11.XFree.argtypes = [ctypes.c_void_p]
            x11.XFlush.argtypes = [ctypes.c_void_p]
            xext.XShapeCombineRectangles.argtypes = [
                ctypes.c_void_p,
                ctypes.c_ulong,
                ctypes.c_int,
                ctypes.c_int,
                ctypes.c_int,
                ctypes.c_void_p,
                ctypes.c_int,
                ctypes.c_int,
                ctypes.c_int,
            ]
            display = x11.XOpenDisplay(None)
        except (OSError, AttributeError):
            return
        if not display:
            return
        self.x11 = x11
        self.xext = xext
        self.display = display
        self.root = x11.XDefaultRootWindow(display)

    def apply(self, window: int) -> None:
        if not self.display:
            return
        parent, _ = self._query(window)
        # Start at Tk's wrapper so no ancestor keeps a default input shape.
        top = parent if parent not in (0, self.root) else window
        for window_id in self._subtree(top):
            self.xext.XShapeCombineRectangles(
                self.display,
                window_id,
                self.SHAPE_INPUT,
                0,
                0,
                None,
                0,
                self.SHAPE_SET,
                self.UNSORTED,
            )
        self.x11.XFlush(self.display)

    def _query(self, window: int) -> tuple[int, list[int]]:
        root = ctypes.c_ulong()
        parent = ctypes.c_ulong()
        children = ctypes.POINTER(ctypes.c_ulong)()
        count = ctypes.c_uint()
        if not self.x11.XQueryTree(
            self.display,
            window,
            ctypes.byref(root),
            ctypes.byref(parent),
            ctypes.byref(children),
            ctypes.byref(count),
        ):
            return 0, []
        kids = [children[i] for i in range(count.value)]
        if children:
            self.x11.XFree(children)
        return parent.value, kids

    def _subtree(self, window: int) -> list[int]:
        _, kids = self._query(window)
        windows = [window]
        for kid in kids:
            windows.extend(self._subtree(kid))
        return windows


class Overlay:
    """One reusable passive window that fades a mode label at screen center."""

    def __init__(self, root: "tk.Misc") -> None:
        self.root = root
        self._fade_job: str | None = None
        self._fade_step = 0

        self.window = tk.Toplevel(root)
        self.window.withdraw()
        self.window.overrideredirect(True)
        self.window.attributes("-topmost", 1)
        self.window.attributes("-alpha", 0.0)
        self.window.configure(bg=MODE_COLORS["BASE"])
        # Override-redirect removes the window from WM management; NOTIFICATION
        # keeps it out of the taskbar and pager, and -topmost supplies ABOVE.
        self.window.wm_attributes("-type", "notification")

        self.canvas = tk.Canvas(
            self.window,
            width=WINDOW_WIDTH,
            height=WINDOW_HEIGHT,
            bd=0,
            highlightthickness=0,
            bg=MODE_COLORS["BASE"],
        )
        self.canvas.pack()
        self._text = self.canvas.create_text(
            WINDOW_WIDTH // 2,
            WINDOW_HEIGHT // 2,
            text="",
            fill="#000000",
            font=("DejaVu Sans", 40, "bold"),
        )

        self.window.update_idletasks()
        self._shape = _InputShape()

    def show_mode(self, mode: str) -> None:
        color = MODE_COLORS.get(mode, MODE_COLORS["BASE"])
        glyph = GLYPHS.get(mode, mode)
        label = f"{glyph} {mode}"
        self._cancel_fade()
        self.canvas.configure(bg=color)
        self.window.configure(bg=color)
        self.canvas.itemconfigure(self._text, text=label)
        # Long mode names overflow the fixed window at a fixed size, so every
        # label picks the largest size that still clears the filled box.
        size = font_size_for(label, WINDOW_WIDTH, WINDOW_HEIGHT)
        self.canvas.itemconfigure(self._text, font=("DejaVu Sans", size, "bold"))
        self._center()
        # Every call resets the timeline, so a rapid switch swaps the label on
        # the same window and restarts the fade without a flicker.
        self._fade_step = 0
        self.window.attributes("-alpha", 1.0)
        self.window.deiconify()
        self.window.update_idletasks()
        # Full-window alpha plus an empty input shape gives click-through on a
        # composited X11 desktop, which is why the plan requires the existing
        # compton or picom setup. Tk creates the canvas X window only when the
        # toplevel first maps, so the shape is applied on every show.
        self._shape.apply(self.window.winfo_id())
        self.window.lift()
        self.window.attributes("-topmost", 1)
        self._fade_tick()

    def hide(self) -> None:
        self._cancel_fade()
        self.window.attributes("-alpha", 0.0)
        self.window.withdraw()

    def _center(self) -> None:
        x = (self.window.winfo_screenwidth() - WINDOW_WIDTH) // 2
        y = (self.window.winfo_screenheight() - WINDOW_HEIGHT) // 2
        self.window.geometry(f"{WINDOW_WIDTH}x{WINDOW_HEIGHT}+{x}+{y}")

    def _fade_tick(self) -> None:
        self._fade_job = None
        self._fade_step += 1
        alpha = 1.0 - (self._fade_step / FADE_STEPS)
        if alpha <= 0.0:
            self.hide()
            return
        self.window.attributes("-alpha", alpha)
        self._fade_job = self.root.after(FADE_STEP_MS, self._fade_tick)

    def _cancel_fade(self) -> None:
        if self._fade_job is not None:
            self.root.after_cancel(self._fade_job)
            self._fade_job = None


def main() -> int:
    if not os.environ.get("DISPLAY"):
        print("kanata-overlay: DISPLAY is unset; overlay needs X11", file=sys.stderr)
        return 0
    if tk is None:
        print("kanata-overlay: tkinter is unavailable; overlay disabled", file=sys.stderr)
        return 0

    root = tk.Tk()
    root.withdraw()
    overlay = Overlay(root)
    # The env override keeps manual checks off the live cache file; normal
    # service runs fall back to MODE_FILE.
    mode_file = os.environ.get("KANATA_MODE_FILE", MODE_FILE)
    last = read_mode(mode_file)

    def poll() -> None:
        nonlocal last
        current = read_mode(mode_file)
        if should_show(last, current):
            overlay.show_mode(current)
        elif current == "BASE" and last != "BASE":
            overlay.hide()
        last = current
        root.after(POLL_MS, poll)

    root.after(POLL_MS, poll)
    try:
        root.mainloop()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
