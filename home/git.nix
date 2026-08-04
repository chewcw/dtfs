{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "ChewCW";
    userEmail = "chwai87@gmail.com";

    extraConfig = {
      diff.tool = "vimdiff";
      difftool = {
        prompt = "false";
        vimdiff.cmd = ''
          vimdiff -u /home/ccw/.vimrc -c "wincmd L" -c "windo set wrap" "$BASE" "$REMOTE"
        '';
      };
      merge.tool = "vimdiff";
      merge.conflictstyle = "diff3";
      mergetool = {
        prompt = "false";
        vimdiff.cmd = ''
          vimdiff -u /home/ccw/.vimrc -c "wincmd J" -c "windo set wrap" "$MERGED" "$LOCAL" "$BASE" "$REMOTE"
        '';
      };
    };

    aliases = {
      g = "git";
      l = "log";
      ll = "log --graph --pretty=format:\"%h %Cred%an %Cblue%aI %Cred%d%Cgreen%s\"";
      f = "fetch";
      b = "branch";
      s = "stage";
      r = "rebase";
      cp = "cherry-pick";
      st = "status";
      c = "commit";
      co = "checkout";
      m = "merge";
      cz = "stash";
    };

    extraConfig = {
      pager.stash = false;
      push.autoSetupRemote = false;
      rebase.rebaseMerges = true;
      rebase.updateRefs = true;
      init.defaultBranch = "main";
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      maintenance.repo = "/home/ccw/Documents/dtfs";
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
    };
  };
}
