{ config, pkgs, ... }:

{
  # Install neovim from nixpkgs
  programs.neovim = {
    enable = true;
    package = pkgs.neovim; # or pin a specific version
    vimAlias = true;
    viAlias = true;
  };

  # Symlink the existing nvim config (lazy.nvim manages plugins at runtime)
  xdg.configFile."nvim" = {
    source = ../HOME/.config/nvim;
    recursive = true;
  };

  # Install system-level tools nvim needs
  home.packages = with pkgs; [
    ripgrep
    fd
    git
    lazygit
    tree-sitter
  ];
}
