{ lib, ... }:

{
  # Define colorscheme as a variable
  options.colorscheme = lib.mkOption {
    type = lib.types.enum [ "dark" "light" ];
    default = "dark";
  };

  config = {
    home.sessionVariables = {
      COLORSCHEME = "dark"; # or "light"
    };

    # Conditional config based on colorscheme
    # (use this in tmux.nix, terminals.nix, etc.):
    #
    #   xdg.configFile."alacritty/alacritty.yml" =
    #     if config.colorscheme == "dark"
    #     then { source = ../HOME/.config/alacritty/alacritty-dark.yml; }
    #     else { source = ../HOME/.config/alacritty/alacritty-light.yml; };
  };
}
