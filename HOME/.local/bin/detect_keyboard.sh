#!/bin/bash

set -e

kill_existing_kanata() {
  # Stop any running systemd kanata services first
  echo "Stopping existing kanata services..."
  systemctl --user stop kanata-65.service kanata-75.service 2>/dev/null || true
  # Also kill any stray kanata instance not under systemd
  if pgrep -x kanata &>/dev/null; then
    echo "Killing stray kanata instance..."
    pkill -x kanata
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

# Register service files and reload daemon
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable kanata-65.service kanata-75.service 2>/dev/null || true

kill_existing_kanata

if detect_royal_kludge_keyboard; then
  echo "Royal Kludge detected, starting kanata-65.service..."
  systemctl --user start kanata-65.service
else
  echo "Royal Kludge not detected, starting kanata-75.service..."
  systemctl --user start kanata-75.service
fi
