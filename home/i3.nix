{ config, pkgs, ... }:

{
  # Install i3 + i3status
  home.packages = with pkgs; [
    i3
    i3status
    i3lock
    dmenu
  ];

  # i3 config (symlinked from existing file)
  xdg.configFile."i3/config".source = ../HOME/.config/i3/config;

  # i3status config
  xdg.configFile."i3status/config".source = ../HOME/.config/i3status/config;

  # Custom scripts used by i3
  home.file.".local/bin/i3status_wrapper.py".source = ../HOME/.local/bin/i3status_wrapper.py;
}
