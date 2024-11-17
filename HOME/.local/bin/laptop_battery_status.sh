#!/bin/env bash

set -e

# Send out notification if the battery level is below 30%
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

if [ -d "/sys/class/power_supply/BAT0" ]; then
  if [ "$(cat /sys/class/power_supply/BAT0/status)" == "Discharging" ]; then
    [[ $(echo "$(cat /sys/class/power_supply/BAT0/capacity | tr -d '\n')" | bc) -le 30 ]] && notify-send -u critical "Battery critically low"
  fi
fi
