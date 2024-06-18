#!/usr/bin/bash

$HOME/.local/bin/connect_monitor.sh;

xset r rate 300 70;

fcitx &>/dev/null;

sudo modprobe --remove psmouse;
bash -c 'sleep 0.2; sudo modprobe psmouse'

sudo timedatectl set-ntp false;
bash -c 'sleep 0.2; timedatectl set-ntp true';

pkill -f pasystray || true;
bash -c 'sleep 0.2; pasystray &>/dev/null &';

pkill -f xcompmgr || true;
bash -c 'sleep 0.2; xcompmgr -c &>/dev/null &';
