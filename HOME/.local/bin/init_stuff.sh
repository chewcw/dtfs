#!/usr/bin/bash

# Hand the X display to the user manager first: X11 services started
# through systemctl --user (kanata-overlay via detect_keyboard.sh,
# rpresent below) inherit the manager's env, not this shell's. Starting
# them before this import makes them exit with no DISPLAY.
if [[ -n "${DISPLAY:-}" ]]; then
  systemctl --user import-environment DISPLAY 2>/dev/null || true
fi

# Run the scripts in the background
$HOME/.local/bin/connect_monitor.sh
$HOME/.local/bin/detect_keyboard.sh

# Run ptrkeys
# systemctl --user start ptrkeys

# Run zhisper
systemctl --user restart zhisper || systemctl --user start zhisper || true

# Run rpresent (needs the X display, imported at the top)
systemctl --user restart rpresent || systemctl --user start rpresent || true

# Use wait to synchronize instead of fixed sleep
sleep 1.5

# Start fcitx5 only if not already running (i3 config normally starts it)
if ! pgrep -x "fcitx5" > /dev/null; then
  fcitx5 -d
fi

# Only reload psmouse if necessary
if lsmod | grep -q psmouse; then
  sudo modprobe --remove psmouse
  sleep 0.2
fi
sudo modprobe psmouse

# Synchronizing time settings more efficiently
# if timedatectl show | grep -q 'NTP=no'; then
timedatectl set-ntp false
sleep 0.2
# fi
timedatectl set-ntp true

# Optimize xset configuration
# Already have this ~/.config/autostart/keyboard-rate.desktop
# But still need this in case of refreshing 
xset r rate 300 70


# Stop and restart pasystray only if it's running
# if pgrep -f "pasystray" > /dev/null; then
  # pkill -f pasystray
  # sleep 0.2
# fi
# pasystray &>/dev/null &

# Stop and restart xcompmgr only if it's necessary
# if pgrep -f "xcompmgr" > /dev/null; then
#   pkill -f xcompmgr
#   sleep 0.2
# fi
# xcompmgr -c &>/dev/null &
