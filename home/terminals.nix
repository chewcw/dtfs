{ config, pkgs, nixGLFlake, lib, ... }:

let
  # Ghostty built with Nix uses Nix-hosted GLib/OpenGL libs. On non-NixOS
  # Linux systems (Debian, Ubuntu, Fedora, Arch, WSL2) it won't launch without
  # a wrapper that exposes them to the GL loader.
  # https://ghostty.org/docs/install/binary
  # NOTE: nixGLIntel is pinned (not nixGLDefault) because auto-detection picks
  # the NVIDIA path on hybrid Intel+NVIDIA laptops when the NVIDIA kernel
  # module is loaded, and GTK4 + NVIDIA + X11 fails to acquire an OpenGL
  # context. The display is driven by Intel here; nixGLIntel gives a working
  # Mesa OpenGL 4.6 context (Ghostty needs >= 4.3).
  # The nixGL flake input arrives as `nixGLFlake` (the bare `nixGL` name is
  # reserved by home-manager's nixGL module).
  # On NixOS and macOS, native Ghostty works without nixGL. NixOS is
  # detected via the /etc/NIXOS marker file (stdenv has no isNixOS attr).
  ghosttyExe = if pkgs.stdenv.isLinux && !(builtins.pathExists /etc/NIXOS)
    then pkgs.writeShellScriptBin "ghostty" ''
      exec ${nixGLFlake.packages."${pkgs.system}".nixGLIntel}/bin/nixGLIntel \
        ${pkgs.ghostty}/bin/ghostty "$@"
    ''
    else pkgs.ghostty;
in
{
  home.packages = [ ghosttyExe pkgs.kitty ];

  # Kitty config
  xdg.configFile."kitty/kitty.conf".source = ../HOME/.config/kitty/kitty.conf;
}
