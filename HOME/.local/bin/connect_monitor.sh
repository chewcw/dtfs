#!/bin/bash

set -e

check() {
	if ! command -v xrandr &> /dev/null; then
		echo "xrandr not installed"
		exit 1
	fi
}

connect_monitor() {
	laptop_screen=0
	hdmi=0
	vga=0

	if [[ "eDP-1 connected" == $(xrandr | grep -E -o "^eDP-1 ((connected)|(disconnected))") ]]; then
		laptop_screen=1
	fi
	if [[ "DP-1 connected" == $(xrandr | grep -E -o "^DP-1 ((connected)|(disconnected))") ]]; then
		vga=1
	fi
	if [[ "HDMI-1 connected" ==  $(xrandr | grep -E -o "^HDMI-1 ((connected)|(disconnected))") ]]; then
		hdmi=1
	fi

	if [[ $laptop_screen == 1 && $vga == 0 && $hdmi == 1 ]]; then
		# home setup
		# source /home/ccw/.zshrc && monitor-home
		xrandr --auto && xrandr \
      --output HDMI-1 --mode 1920x1080 \
      --right-of \
      eDP-1 --primary --mode 1920x1080
	elif [[ $laptop_screen == 1 && $vga == 1 && $hdmi == 1 ]]; then
		# maple setup
		# source /home/ccw/.zshrc && monitor-maple
		xrandr --auto && xrandr --output \
    eDP-1 --off \
    --output DP-1 --mode 1920x1080 \
    --left-of HDMI-1 --mode 1920x1080
	else
		xrandr --auto
	fi
}

check
connect_monitor

