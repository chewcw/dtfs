#!/bin/bash

# run my all-purpose development docker container
# with all necessary arguments provided

set -e

DOCKER=$(which docker)
IMAGE=chewcw/dev:004
TERM=$TERM
DISPLAY=$DISPLAY

$DOCKER run \
  -it \
  `# this is to make sure the neovim inside the container can have undercurl` \
  -e TERM=$TERM \
  `# these are for xclip/xsel to work inside the container` \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --user 1000 \
  `# working directory` \
  --workdir /workspace \
  `# used to run following commands` \
  --entrypoint=bash \
  `# can append any desired argument` \
  $1 \
  $IMAGE \
  -c "wget https://github.com/alacritty/alacritty/releases/download/v0.12.0/alacritty.info -O /tmp/alacritty.info && \
    sudo tic -xe alacritty,alacritty-direct /tmp/alacritty.info && \
    zsh"
