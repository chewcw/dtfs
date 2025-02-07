#!/bin/bash

set -e

detect_usb_keyboard() {
  if command -v lsusb &>/dev/null; then
      # Royal Kludge
      if lsusb | grep -qi "0c45:8018"; then
        sudo sed -i 's/caps2esc -m 3/caps2esc -m 4/' /etc/interception/udevmon.yaml
        sudo systemctl restart udevmon
        return 0
      else
        sudo sed -i 's/caps2esc -m 4/caps2esc -m 3/' /etc/interception/udevmon.yaml
        sudo systemctl restart udevmon
        return 0
      fi
  else
      echo "lsusb is not installed. Please install usbutils."
      return 1
  fi
  return 1
}

detect_usb_keyboard
