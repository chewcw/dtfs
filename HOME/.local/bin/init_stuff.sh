#!/usr/bin/bash

# Run the scripts in the background
$HOME/.local/bin/connect_monitor.sh
$HOME/.local/bin/detect_keyboard.sh

# Use wait to synchronize instead of fixed sleep
sleep 1.5

# Start fcitx only if not already running
if ! pgrep -x "fcitx" > /dev/null; then
  fcitx &>/dev/null &
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
