{
  config,
  pkgs,
  lib,
  ...
}:

let
  palette = config.colorScheme.palette;
in

lib.mkIf pkgs.stdenv.isLinux {
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # Monitors - adjust to your setup
      # Use `hyprctl monitors` to find names
      monitor = [
        ",preferred,auto,1"
      ];

      # NVIDIA env vars for Wayland
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "NVD_BACKEND,direct"
      ];

      cursor = {
        no_hardware_cursors = true; # NVIDIA needs software cursors
      };

      # Startup apps
      exec-once = [
        "waybar"
        "hyprpaper"
        "nm-applet --indicator"  # WiFi/network tray icon
        "blueman-applet"         # Bluetooth tray icon
        "noisetorch -i"          # Auto-load noise cancellation on default mic
        "discord"
      ];

      # General
      general = {
        gaps_in = 8;
        gaps_out = 20;
        border_size = 3;
        "col.active_border" = "rgb(${palette.base0D})";
        "col.inactive_border" = "rgb(${palette.base04})";
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        shadow = {
          enabled = false;
        };
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "ease, 0.25, 0.1, 0.25, 1";
        animation = [
          "windows, 1, 4, ease"
          "windowsOut, 1, 4, ease, popin 80%"
          "fade, 1, 4, ease"
          "workspaces, 1, 3, ease"
        ];
      };

      # Dwindle layout (similar to Aerospace tiles)
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Input
      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
        # Caps Lock remapping handled by keyd service
        follow_mouse = 1;
        sensitivity = 0;
      };

      # Misc
      misc = {
        force_default_wallpaper = 0;
      };

      # ── Keybindings (mirroring your Aerospace config) ──
      "$mod" = "ALT";

      bind = [
        # Window navigation (alt-hjkl like Aerospace)
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        # Window movement (alt+shift-hjkl)
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        # Fullscreen
        "$mod SHIFT, 0, fullscreen, 0"
        "CTRL ALT SHIFT SUPER, U, fullscreen, 0"  # Hyper (Caps Lock via keyd)

        # Workspace navigation (matching Aerospace names → numbers)
        # 1=social 2=spec 3=obs 4=code 5=notes 6=perso 7=browser 8=terminal 9=db 10=claude
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Quick access letters (like Aerospace)
        "$mod, S, workspace, 1"   # social
        "$mod, D, workspace, 4"   # code
        "$mod, A, workspace, 7"   # browser
        "$mod, W, workspace, 8"   # terminal
        "$mod, B, workspace, 9"   # db

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Toggle floating (alt+shift-space like Aerospace)
        "$mod SHIFT, SPACE, togglefloating"

        # Layout toggles
        "$mod, SLASH, togglesplit"

        # Resize
        "$mod SHIFT, EQUAL, resizeactive, 50 0"
        "$mod SHIFT, MINUS, resizeactive, -50 0"

        # Close window
        "$mod, Q, killactive"

        # App launchers
        "$mod, RETURN, exec, kitty"
        "$mod, SPACE, exec, wofi --show drun"

        # Move workspace to other monitor
        "CTRL ALT SHIFT, RIGHT, movecurrentworkspacetomonitor, r"
        "CTRL ALT SHIFT, LEFT, movecurrentworkspacetomonitor, l"
        "CTRL ALT SHIFT, UP, movecurrentworkspacetomonitor, u"
        "CTRL ALT SHIFT, DOWN, movecurrentworkspacetomonitor, d"

        # Mac-like keybindings (Super = Cmd)
        "SUPER, C, exec, wl-copy"          # Copy
        "SUPER, V, exec, wl-paste"         # Paste
        "SUPER, Z, exec, wtype -M ctrl z"  # Undo
        "SUPER, X, exec, wtype -M ctrl x"  # Cut
        "SUPER, A, exec, wtype -M ctrl a"  # Select all
        "SUPER, S, exec, wtype -M ctrl s"  # Save
        "SUPER, F, exec, wtype -M ctrl f"  # Find
        "SUPER, W, exec, wtype -M ctrl w"  # Close tab
        "SUPER, T, exec, wtype -M ctrl t"  # New tab
        "SUPER, R, exec, wtype -M ctrl r"  # Refresh
        "SUPER SHIFT, Z, exec, wtype -M ctrl -M shift z"  # Redo
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Window rules (matching Aerospace on-window-detected)
      windowrule = [
        "match:class Slack, workspace 1"
        "match:class discord, workspace 1"
        "match:class thunderbird, workspace 1"
        "match:class Linear, workspace 2"
        "match:class Code, workspace 4"
        "match:class jetbrains-goland, workspace 4"
        "match:class dev.zed.Zed, workspace 4"
        "match:class notion, workspace 5"
        "match:class firefox, workspace 7"
        "match:class zen, workspace 7"
        "match:class google-chrome, workspace 7"
        "match:class kitty, workspace 8"
        "match:class DBeaver, workspace 9"
        "match:class claude, workspace 10"
      ];
    };
  };

  # Waybar (status bar - equivalent to SketchyBar)
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];

        clock.format = "{:%H:%M  %a %d %b}";
        pulseaudio = {
          format = "VOL {volume}%";
          on-click = "pavucontrol";
        };
        network = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = "  ETH";
          format-disconnected = "  OFF";
        };
        battery = {
          format = "BAT {capacity}%";
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        color: #${palette.base05};
      }
      window#waybar {
        background-color: rgba(0, 0, 0, 0);
      }
      #workspaces button {
        padding: 0 8px;
        color: #${palette.base04};
        border-bottom: 2px solid transparent;
      }
      #workspaces button.active {
        color: #${palette.base0D};
        border-bottom: 2px solid #${palette.base0D};
      }
      #clock, #pulseaudio, #network, #battery, #tray {
        padding: 0 10px;
      }
    '';
  };

  # Wofi (app launcher)
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = 500;
      height = 300;
      prompt = "Run...";
    };
    style = ''
      window {
        background-color: #${palette.base00};
        border: 2px solid #${palette.base0D};
        border-radius: 10px;
      }
      #input {
        background-color: #${palette.base01};
        color: #${palette.base05};
        border-radius: 8px;
        padding: 8px;
      }
      #entry:selected {
        background-color: #${palette.base0D};
        color: #${palette.base00};
      }
    '';
  };

  # Terminal
  programs.kitty = {
    enable = true;
    settings = {
      background = "#${palette.base00}";
      foreground = "#${palette.base05}";
      font_family = "JetBrainsMono Nerd Font";
      font_size = 13;
      window_padding_width = 10;
      confirm_os_window_close = 0;
    };
  };

  # Packages for the Hyprland desktop
  home.packages = with pkgs; [
    hyprpaper       # wallpaper
    wl-clipboard    # clipboard
    wtype           # keyboard input simulation (for Mac-like bindings)
    wofi            # app launcher
    grim            # screenshots
    slurp           # area selection
    pavucontrol     # audio GUI
    networkmanagerapplet
    wev             # Wayland event viewer (debug keybindings)
  ];
}
