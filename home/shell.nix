{ config, pkgs, ... }:

{
  # Install zsh + plugins from nixpkgs
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      c = "code -r";
      dc = "docker-compose";
      k = "kubectl";
      v = "nvim";
      gforeachref = "git for-each-ref --sort=committerdate --format '%(refname) on %(color:bold blue)%(committerdate) %(color:bold white) by %(color:green) %(committername)%(committeremail)'";
    };

    # oh-my-zsh integration
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "vi-mode" "zsh-autosuggestions" ];
    };

    # Init extra content (functions, fzf, etc.)
    initExtra = ''
      # vi-mode keybindings
      KEYTIMEOUT=1
      bindkey -v
      bindkey -M viins '^b' vi-backward-char
      bindkey -M viins '^f' vi-forward-char
      bindkey -M viins '^[b' backward-word
      bindkey -M viins '^[f' forward-word

      # fzf
      source <(fzf --zsh)
      export FZF_DEFAULT_COMMAND="find -L"
      export FZF_ALT_C_COMMAND="find ."
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_COMPLETION_TRIGGER=','
      export FZF_DEFAULT_OPTS="
        --style minimal --preview 'fzf-preview.sh {}'
        --no-height
        --reverse
      "

      # fzf functions
      fif() {
        if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
        rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
      }

      fkill() {
        local pid
        if [ "$UID" != "0" ]; then
          pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
        else
          pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        fi
        if [ "x$pid" != "x" ]; then echo $pid | xargs kill -''${1:-9}; fi
      }

      # git branch helpers
      fbr() {
        local branches branch
        branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)")
        branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m)
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
      }

      # Environment
      export EDITOR=nvim
      export VISUAL=nvim
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#626262'
      export VI_MODE_SET_CURSOR=false
      export PATH=$PATH:$HOME/.local/bin/kubectl/
      export PATH=$PATH:/home/ccw/.rustup/toolchains/1.93.0-x86_64-unknown-linux-gnu/bin
      eval "$(mise activate zsh)"
    '';
  };

  # Install fzf, kubectl completion
  home.packages = with pkgs; [
    fzf
    kubectl
  ];
}
