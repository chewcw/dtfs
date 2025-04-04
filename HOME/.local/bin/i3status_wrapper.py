#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# This script is a simple wrapper which prefixes each i3status line with custom
# information. It is a python reimplementation of:
# http://code.stapelberg.de/git/i3status/tree/contrib/wrapper.pl
#
# To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/i3status/contrib/wrapper.py
# In the 'bar' section.
#
# In its current version it will display the cpu frequency governor, but you
# are free to change it to display whatever you like, see the comment in the
# source code below.
#
# © 2012 Valentin Haenel <valentin.haenel@gmx.de>
#
# This program is free software. It comes without any warranty, to the extent
# permitted by applicable law. You can redistribute it and/or modify it under
# the terms of the Do What The Fuck You Want To Public License (WTFPL), Version
# 2, as published by Sam Hocevar. See http://sam.zoy.org/wtfpl/COPYING for more
# details.


# Accompanying i3status.conf stanza:
#   order += "volume mic"
#   volume mic {
#           format = "MIC placeholder"
#           device = "default"
#           mixer = "Capture"
#   }


import sys
import json

try:
    import pulsectl
    pulse = pulsectl.Pulse('i3status-wrapper')
except ImportError:
    pulse = None

def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()

def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()

if __name__ == '__main__':
    # Skip the first line which contains the version header.
    print_line(read_line())

    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # ignore comma at start of lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        j = json.loads(line)

        for index, field in enumerate(j):
            if field['name'] == 'volume' and 'Capture' in field['instance']:
                if pulse:
                    default_source_name = pulse.server_info().default_source_name
                    source = pulse.get_source_by_name(default_source_name)
                    muted = source.mute
                    # add volume to the output if you wish:
                    #volume_percent = '%d%%' % (source.volume.value_flat*100)
                    if not muted:
                        field['full_text'] = '\uf130 mic'
                        field['color'] = '#ffffff'
                    else:
                        field['full_text'] = '\uf131 (mute)'
                        field['color'] = '#FFFF00'
                else:
                    del j[index]

        # and echo back new encoded json
        print_line(prefix+json.dumps(j))
