#!/bin/bash

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

	# Laptop screen and HDMI
	if [[ $laptop_screen == 1 && $vga == 0 && $hdmi == 1 ]]; then
		# Working at my office desk
		monitor_prop=$(xrandr --prop | grep -A3 HDMI-1 | grep -A2 EDID | xargs)
		if [[ "${monitor_prop}" == "${yny_office_desk_monitor_edid}" || "${monitor_prop}" == "${yny_office_desk_monitor_edid2}" ]]; then
			xrandr --output eDP-1 --mode 1920x1080 --primary --pos 0x0 \
				--output HDMI-1 --mode 1920x1080 --pos 1920x0
			return
		fi

		# Other HDMI connection
		prompt_user
		c=$?

		if [ $c -eq 99 ]; then
			xrandr --auto
			return
		fi

		if [ $c -eq 0 ]; then
				xrandr --output eDP-1 --mode 1920x1080 --primary --pos 1920x0 \
						--output HDMI-1 --mode 1920x1080 --pos 0x0
		elif [ $c -eq 1 ]; then
				xrandr --output eDP-1 --mode 1920x1080 --primary --pos 0x0 \
						--output HDMI-1 --mode 1920x1080 --pos 1920x0
		elif [ $c -eq 2 ]; then
				xrandr --output eDP-1 --mode 1920x1080 --primary --pos 1920x0 \
						--output HDMI-1 --mode 1600x900 --pos 0x0
		elif [ $c -eq 3 ]; then
				xrandr --output eDP-1 --mode 1920x1080 --primary --pos 0x0 \
						--output HDMI-1 --mode 1600x900 --pos 1920x0
		elif [ $c -eq 4 ]; then
				xrandr --output eDP-1 --mode 1920x1080 --primary --pos 0x0 \
						--output HDMI-1 --mode 1920x1200 --pos 1920x0
		elif [ $c -eq 5 ]; then
				xrandr --output eDP-1 --mode 1920x1080 --primary --pos 0x0 \
						--output HDMI-1 --mode 1920x1200 --pos 1920x0
		fi

	elif [[ $laptop_screen == 1 && $vga == 1 && $hdmi == 1 ]]; then
		# Home office
		xrandr --output eDP-1 --off \
			--output DP-1 --mode 1920x1080 --primary --pos 0x0 \
			--output HDMI-1 --mode 1920x1200 --pos 1920x0
	else
		xrandr --auto
	fi
}

prompt_user() {
		echo "HDMI connection detected. Choose an option:"
		echo "1) Left (1920x1080)"
		echo "2) Right (1920x1080)"
		echo "3) Left (1600x900)"
		echo "4) Right (1600x900)"
		echo "5) Left (1920x1200)"
		echo "6) Right (1920x1200)"
		if ! read -r -t 5 -p "Enter choice [1/2/3/4/5/6]: " choice; then
			echo "No input received in 5 seconds."
			return 99
		fi

		case $choice in
				1) return 0 ;;
				2) return 1 ;;
				3) return 2 ;;
				4) return 3 ;;
				5) return 4 ;;
				6) return 5 ;;
				*) echo "Invalid choice, defaulting to Left (1920x1080)"; return 0 ;;
		esac
}

check
connect_monitor
