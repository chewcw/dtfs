{ config, pkgs, ... }:

{
  # Scripts installed to ~/.local/bin
  home.file = {
    ".local/bin/dev.sh".source = ../HOME/.local/bin/dev.sh;
    ".local/bin/detect_keyboard.sh".source = ../HOME/.local/bin/detect_keyboard.sh;
    ".local/bin/connect_monitor.sh".source = ../HOME/.local/bin/connect_monitor.sh;
    ".local/bin/init_stuff.sh".source = ../HOME/.local/bin/init_stuff.sh;
    ".local/bin/laptop_battery_status.sh".source = ../HOME/.local/bin/laptop_battery_status.sh;
    ".local/bin/toggle_i3_bar.sh".source = ../HOME/.local/bin/toggle_i3_bar.sh;
    ".local/bin/projecteur_action.sh".source = ../HOME/.local/bin/projecteur_action.sh;
    ".local/bin/date.sh".source = ../HOME/.local/bin/date.sh;
    ".local/bin/gromit_mpx_action.sh".source = ../HOME/.local/bin/gromit_mpx_action.sh;
    ".local/bin/toggle-colorscheme.sh".source = ../HOME/.local/bin/toggle-colorscheme.sh;
    # Binary blobs
    ".local/bin/gromit-mpx".source = ../HOME/.local/bin/gromit-mpx;
    ".local/bin/boomer".source = ../HOME/.local/bin/boomer;
  };

  # Battery status as a Home Manager systemd user service + timer
  # (replaces usr/lib/systemd/user/* from the old setup)
  systemd.user.services.laptop-battery-status = {
    Unit = {
      Description = "Laptop battery status notification";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/laptop_battery_status.sh";
    };
  };

  systemd.user.timers.laptop-battery-status = {
    Unit = {
      Description = "Periodic laptop battery status check";
    };
    Timer = {
      OnCalendar = "*-*-* *:*:00";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
