{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
  ];

  # Kitty config
  xdg.configFile."kitty/kitty.conf".source = ../HOME/.config/kitty/kitty.conf;
}
