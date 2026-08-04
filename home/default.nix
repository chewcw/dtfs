{ config, pkgs, lib, ... }:

{
  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Basic user info
  home = {
    username = "ccw";
    homeDirectory = "/home/ccw";
    stateVersion = "24.11";
  };

  # Import module files
  imports = [
    ./shell.nix
    ./git.nix
    ./nvim.nix
    ./i3.nix
    ./tmux.nix
    ./terminals.nix
    ./tools.nix
    ./scripts.nix
    ./pi.nix
    ./skills.nix
  ];

  # Fonts
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
  ];
}
