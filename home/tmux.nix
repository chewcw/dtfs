{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "M-C-b";
    shell = "/usr/bin/zsh";
    terminal = "tmux-256color";
    escapeTime = 0;
    mouse = true;
    historyLimit = 50000;

    plugins = with pkgs.tmuxPlugins; [
      { plugin = sensible; }
      { plugin = yank; }
      { plugin = resurrect; }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
      { plugin = open; }
      {
        plugin = gruvbox;
        extraConfig = ''
          set -g @tmux-gruvbox 'dark'
        '';
      }
    ];

    # Custom keybindings + extra config
    extraConfig = ''
      # copy mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'V' send -X select-line
      bind-key -T copy-mode-vi 'r' send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -in -selection clipboard"

      # custom keymap
      bind-key 'h' select-pane -L
      bind-key 'j' select-pane -D
      bind-key 'k' select-pane -U
      bind-key 'l' select-pane -R

      # with current path
      bind-key c new-window -c "#{pane_current_path}"
      bind-key - split-window -c "#{pane_current_path}"
      bind-key \\ split-window -h -c "#{pane_current_path}"
      bind-key x kill-pane

      # resize
      bind-key -r C-k resize-pane -U 5
      bind-key -r C-j resize-pane -D 5
      bind-key -r C-h resize-pane -L 5
      bind-key -r C-l resize-pane -R 5

      # search
      set -g @open-B 'https://www.bing.com/search?q='
      set -g @open-S 'https://www.google.com/search?q='
      set -g @open-D 'https://www.duckduckgo?q='

      # true colors
      set -ga terminal-overrides ",xterm-256color:Tc"
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';
  };
}
