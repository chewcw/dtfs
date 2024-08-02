#!/usr/bin/bash

set -e

sleep 0.2s;
DATE_COMMAND=`date +"%Y-%m-%d (%a) %R"`
xdotool type "$DATE_COMMAND"
