#!/usr/bin/bash

set -e

# if pgrep projecteur >/dev/null; then
#   projecteur -c quit;
# fi

if ! pgrep gromit-mpx >/dev/null; then
  # the reason to do this is because somehow, sometimes when i opened gromit-mpx, the
  # screen will dimmed, then i need to close it and open it again.
  gromit-mpx &
  job_pid=$!;
  sleep 0.1;
  kill $job_pid;
  gromit-mpx -a;
else
  pkill gromit-mpx || $(sleep 0.5 && gromit-mpx -a);
fi
