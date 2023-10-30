#!/bin/bash

# run my all-purpose development docker container
# with all necessary arguments provided

set -e

DOCKER=$(which docker)
IMAGE=chewcw/development:1.0.1-nvim-initialized
TERM=$TERM
DISPLAY=$DISPLAY

$DOCKER run \
  -it \
  `# this is to make sure the neovim inside the container can have undercurl` \
  `# must use alacritty in this case` \
  -e TERM=$TERM \
  `# these are for xclip/xsel to work inside the container` \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  `# can append any desired argument` \
  $1 \
  $IMAGE \
