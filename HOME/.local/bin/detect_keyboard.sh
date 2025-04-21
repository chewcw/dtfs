#!/bin/bash

set -e

detect_royal_kludge_keyboard() {
  # Check for USB connection
  if command -v lsusb &>/dev/null; then
    if lsusb | grep -qi "0c45:8018"; then
      # Royal Kludge detected via USB
      sudo sed -i 's/caps2esc -m 3/caps2esc -m 4/' /etc/interception/udevmon.yaml
      sudo systemctl restart udevmon
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
      sudo sed -i 's/caps2esc -m 3/caps2esc -m 4/' /etc/interception/udevmon.yaml
      sudo systemctl restart udevmon
      return 0
    fi
  else
    echo "bluetoothctl is not installed. Please install bluez."
  fi

  # If neither found, revert config
  sudo sed -i 's/caps2esc -m 4/caps2esc -m 3/' /etc/interception/udevmon.yaml
  sudo systemctl restart udevmon
  return 1
}

detect_royal_kludge_keyboard
