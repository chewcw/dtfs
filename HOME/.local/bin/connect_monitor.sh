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

	yny_office_desk_monitor_edid="EDID: 00ffffffffffff0010ac4a4258474d41 2521010380351e78ea6785a854529f27"
  yny_office_desk_monitor_edid2="EDID: 00ffffffffffff0010ac4a4258324641 1d21010380351e78ea6785a854529f27"

	if [[ $laptop_screen == 1 && $vga == 0 && $hdmi == 1 ]]; then
	# work in my office desk
		monitor_prop=$(xrandr --prop | grep -A3 HDMI-1 | grep -A2 EDID | xargs)
		if [[ "${monitor_prop}" == "${yny_office_desk_monitor_edid}" || "${monitor_prop}" == "${yny_office_desk_monitor_edid2}" ]]; then
			xrandr --output eDP-1 --mode 1920x1080 --primary --pos 0x0 \
				--output HDMI-1 --mode 1920x1080 --pos 1920x0
			return
		fi
		# work in other places (like meeting room, etc.)
		xrandr --output eDP-1 --mode 1920x1080 --primary --pos 0x0 \
			--output HDMI-1 --mode 1600x900 --pos 1920x0
	elif [[ $laptop_screen == 1 && $vga == 1 && $hdmi == 1 ]]; then
		# home setup
		xrandr --output eDP-1 --off \
			--output DP-1 --mode 1920x1080 --primary --pos 0x0 \
			--output HDMI-1 --mode 1920x1200 --pos 1920x0
	else
		xrandr --auto
	fi
}

check
connect_monitor

