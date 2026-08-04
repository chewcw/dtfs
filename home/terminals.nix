{ config, pkgs, nixGL, lib, ... }:

let
  # Ghostty built with Nix uses Nix-hosted GLib/OpenGL libs. On non-NixOS
  # systems (Debian) it won't launch without a wrapper that exposes them to
  # the GL loader. nixGLDefault handles this.
  # https://ghostty.org/docs/install/binary
  ghosttyWrapper = pkgs.writeShellScriptBin "ghostty" ''
    exec ${nixGL.packages."${pkgs.system}".default}/bin/nixGLDefault \
      ${pkgs.ghostty}/bin/ghostty "$@"
  '';
in
{
  home.packages = with pkgs; [
    kitty
    ghostty
    ghosttyWrapper
  ];

  # Kitty config
  xdg.configFile."kitty/kitty.conf".source = ../HOME/.config/kitty/kitty.conf;
}
