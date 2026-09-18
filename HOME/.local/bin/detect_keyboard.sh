#!/bin/bash

set -e

kill_existing_kanata() {
  # Kill running kanata instance first, if any
  if pgrep -x kanata &>/dev/null; then
    echo "Killing existing kanata instance..."
    pkill -x kanata
    # Give it a moment to exit before starting a new one
    sleep 0.5
  fi
}

detect_royal_kludge_keyboard() {
  # Check for USB connection
  if command -v lsusb &>/dev/null; then
    if lsusb | grep -qi "0c45:8018"; then
      # Royal Kludge detected via USB
      return 0
    fi
  else
    echo "lsusb is not installed. Please install usbutils."
  fi

  # Check for Bluetooth connection
  if command -v bluetoothctl &>/dev/null; then
    # Look for a connected Royal Kludge device by name
    if bluetoothctl info | grep -qi "RK-Keyboard 5.1"; then
      # Royal Kludge detected via Bluetooth
      return 0
    fi
  else
    echo "bluetoothctl is not installed. Please install bluez."
  fi

  return 1
}

kill_existing_kanata

if detect_royal_kludge_keyboard; then
  echo "Royal Kludge detected, starting kanata with 65-key config..."
  nohup kanata -c "$HOME/.config/kanata/kanata-vim-65.kbd" >>/tmp/kanata.log 2>&1 & disown
else
  echo "Royal Kludge not detected, starting kanata with 75-key config..."
  nohup kanata -c "$HOME/.config/kanata/kanata-vim-75.kbd" >>/tmp/kanata.log 2>&1 & disown
fi
