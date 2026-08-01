{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    flameshot
    copyq
    gromit-mpx
    projecteur
    fcitx5
    fcitx5-configtool
    fcitx5-mozc
    fcitx5-pinyin
  ];

  # Tool configs (symlinked from existing files)
  xdg.configFile."flameshot/flameshot.ini".source = ../HOME/.config/flameshot/flameshot.ini;
  xdg.configFile."gromit-mpx.cfg".source = ../HOME/.config/gromit-mpx.cfg;
  xdg.configFile."gromit-mpx.ini".source = ../HOME/.config/gromit-mpx.ini;
  xdg.configFile."copyq/copyq.conf".source = ../HOME/.config/copyq/copyq.conf;
  xdg.configFile."copyq/copyq-commands.ini".source = ../HOME/.config/copyq/copyq-commands.ini;
  xdg.configFile."Projecteur/Projecteur.conf".source = ../HOME/.config/Projecteur/Projecteur.conf;

  # Lazygit config
  xdg.configFile."jesseduffield/lazygit/config.yml".source = ../HOME/.config/jesseduffield/lazygit/config.yml;

  # fcitx5 config (im-config selection is system-level, outside HM scope)
  xdg.configFile."fcitx5/config".source = ../HOME/.config/fcitx5/config;

  # dunst (currently etc/xdg/dunst, system-level in old setup)
  xdg.configFile."dunst/dunstrc".source = ../../etc/xdg/dunst/dunstrc;
}
