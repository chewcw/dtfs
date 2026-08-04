{ config, pkgs, nixGL, lib, ... }:

let
  # Ghostty built with Nix uses Nix-hosted GLib/OpenGL libs. On non-NixOS
  # Linux systems (Debian, Ubuntu, Fedora, Arch, WSL2) it won't launch without
  # a wrapper that exposes them to the GL loader. nixGLDefault handles this.
  # https://ghostty.org/docs/install/binary
  # On NixOS and macOS, native Ghostty works without nixGL.
  ghosttyExe = if pkgs.stdenv.isLinux && !pkgs.stdenv.isNixOS
    then pkgs.writeShellScriptBin "ghostty" ''
      exec ${nixGL.packages."${pkgs.system}".default}/bin/nixGLDefault \
        ${pkgs.ghostty}/bin/ghostty "$@"
    ''
    else pkgs.ghostty;
in
{
  home.packages = [ ghosttyExe pkgs.kitty ];

  # Kitty config
  xdg.configFile."kitty/kitty.conf".source = ../HOME/.config/kitty/kitty.conf;
}
