#!/bin/bash

# run my all-purpose development docker container
# with all necessary arguments provided

set -e

DOCKER=$(which docker)
: "${IMAGE:=chewcw/development:latest}"
TERM=$TERM
DISPLAY=$DISPLAY

$DOCKER run \
  -it \
  `# this is to make sure the neovim inside the container can have undercurl` \
  `# must use alacritty in this case` \
  -e TERM=$TERM \
  -e DISPLAY=$DISPLAY \
  -e EDITOR=nvim \
  `# this is for xclip/xsel to work inside the container` \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  `# these is to share the host's XServer with the container` \
  -v $HOME/.Xauthority:/root/.Xauthority \
  `# can append any desired argument` \
  $1 \
  $IMAGE \
