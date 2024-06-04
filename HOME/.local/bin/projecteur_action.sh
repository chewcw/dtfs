#!/usr/bin/bash

set -e

CONFIG_FILE="$HOME/.config/Projecteur/Projecteur.conf"

default() {
  cat <<EOF > "$CONFIG_FILE"
# Function in \$HOME/.local/bin/projecteur_action.sh will overwrite this file
[General]
borderColor=@Variant(\\0\\0\\0\\x43\\x1\\xff\\xffss\\xd2\\xd2\\x16\\x16\\0\\0)
borderOpacity=1
borderSize=3
cursor=13
dotColor=@Variant(\\0\\0\\0\\x43\\x1\\xff\\xff\\xff\\xff\\0\\0\\0\\0\\0\\0)
dotOpacity=0.7
dotSize=10
enableZoom=false
zoomFactor=1.5
multiScreenOverlay=false
shadeColor=@Variant(\\0\\0\\0\\x43\\x1\\xff\\xff\\0\\0\\0\\0\\0\\0\\0\\0)
shadeOpacity=0.8
showBorder=true
showCenterDot=true
showSpotShade=true
spotShape=spotshapes/Circle.qml
spotOverlay=true
spotSize=30

EOF
}

increaseSpotSizeBy5() {
  # Read current spotSize
  currentSpotSize=$(grep -Po '(?<=^spotSize=).*$' "$CONFIG_FILE")

  # Check if spotSize was found
  if [ -z "$currentSpotSize" ]; then
    exit 1
  fi

  # Increment spotSize by 5
  newSpotSize=$((currentSpotSize + 5))

  projecteur -c spot.size=$newSpotSize spot=toggle
}

decreaseSpotSizeBy5() {
  # Read current spotSize
  currentSpotSize=$(grep -Po '(?<=^spotSize=).*$' "$CONFIG_FILE")

  # Check if spotSize was found
  if [ -z "$currentSpotSize" ]; then
    exit 1
  fi

  # Decrement spotSize by 5
  if [ "$currentSpotSize" -gt 10 ]; then
    newSpotSize=$((currentSpotSize - 5))
  else
    newSpotSize=10
  fi

  projecteur -c spot.size=$newSpotSize spot=toggle
}

zoomIn() {
  # Read current zoomFactor
  currentZoomFactor=$(grep -Po '(?<=^zoomFactor=).*$' "$CONFIG_FILE")

  # Check if zoomFactor was found
  if [ -z "$currentZoomFactor" ]; then
    exit 1
  fi

  # Increment zoomFactor by 0.5
  newZoomFactor=$(awk "BEGIN {print $currentZoomFactor + 0.5}")

  # Update configuration file
  sed -i \
    -e 's/^enableZoom=.*$/enableZoom=true/' \
    -e "s/^zoomFactor=.*$/zoomFactor=$newZoomFactor/" \
    "$CONFIG_FILE"
}

zoomOut() {
  # Read current zoomFactor
  currentZoomFactor=$(grep -Po '(?<=^zoomFactor=).*$' "$CONFIG_FILE")

  # Check if zoomFactor was found
  if [ -z "$currentZoomFactor" ]; then
    exit 1
  fi

  # Decrement zoomFactor by 1
  newZoomFactor=$(awk "BEGIN {print $currentZoomFactor - 0.5}")

  # Ensure newZoomFactor does not go below 1.0
  if (( $(awk "BEGIN {print ($newZoomFactor < 1.0)}") )); then
    newZoomFactor=1.0
  fi

  # Update configuration file
  sed -i \
    -e 's/^enableZoom=.*$/enableZoom=true/' \
    -e "s/^zoomFactor=.*$/zoomFactor=$newZoomFactor/" \
    "$CONFIG_FILE"
}

disableZoom() {
  # Update configuration file
  sed -i \
    -e 's/^enableZoom=.*$/enableZoom=false/' \
    "$CONFIG_FILE"
}

case "$1" in
  default)
    default
    ;;
  increaseSpotSize)
    increaseSpotSizeBy5
    ;;
  decreaseSpotSize)
    decreaseSpotSizeBy5
    ;;
  zoomIn)
    zoomIn
    ;;
  zoomOut)
    zoomOut
    ;;
  disableZoom)
    disableZoom
    ;;
  *)
    echo "Usage: $0 {default|increaseSpotSize|decreaseSpotSize|zoomIn|zoomOut|disableZoom}"
    exit 1
    ;;
esac
