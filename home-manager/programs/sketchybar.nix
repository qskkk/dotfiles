{
  config,
  pkgs,
  lib,
  ...
}:

let
  palette = config.colorScheme.palette;
  toHex = c: "0xff${c}";
  color_background = toHex palette.base00;
  color_foreground = toHex palette.base05;
  color_font = toHex palette.base05;
  color_border = toHex palette.base03;
  color_red = toHex palette.base08;
  color_green = toHex palette.base0B;
  color_blue = toHex palette.base0D;
  color_yellow = toHex palette.base0A;
  color_orange = toHex palette.base09;
  color_purple = toHex palette.base0E;
  color_pink = toHex palette.base0F;
  color_teal = toHex palette.base0C;
in
{
  # Install sketchybar
  home.packages = with pkgs; [
    sketchybar
  ];

  # SketchyBar configuration
  home.file.".config/sketchybar/sketchybarrc" = {
    text = ''
      #!/usr/bin/env bash

      # This is a demo config to showcase some of the most important commands.
      # It is meant to be changed and configured, as it is intentionally kept sparse.
      # For a (much) more advanced configuration example see my dotfiles:
      # https://github.com/FelixKratz/dotfiles

      # Ensure HOME is correctly set

      CONFIG_DIR="${config.home.homeDirectory}/.config/sketchybar"
      PLUGIN_DIR="$CONFIG_DIR/plugins"
      NERD_FONT="Hack Nerd Font Mono"

      # Define colors from nix-colors palette
      COLOR_BACKGROUND=${color_background}
      COLOR_FONT=${color_font}
      COLOR_BORDER=${color_border}
      COLOR_YELLOW=${color_yellow}
      COLOR_CYAN=${color_teal}
      COLOR_MAGENTA=${color_purple}
      COLOR_WHITE=${color_foreground}
      COLOR_BLUE=${color_blue}
      COLOR_RED=${color_red}
      COLOR_GREEN=${color_green}

      # Define icons inline
      ICONS_SPACE=("1" "2" "3" "4" "5" "6" "7" "8" "9")

      # Try to source external files if they exist, but don't fail if they don't
      if [ -f "$PLUGIN_DIR/assets/colors.sh" ]; then
        source "$PLUGIN_DIR/assets/colors.sh"
      fi
      if [ -f "$PLUGIN_DIR/assets/icons.sh" ]; then
        source "$PLUGIN_DIR/assets/icons.sh"
      fi

      ##### Bar Appearance #####
      # Configuring the general appearance of the bar.
      # These are only some of the options available. For all options see:
      # https://felixkratz.github.io/SketchyBar/config/bar
      # If you are looking for other colors, see the color picker:
      # https://felixkratz.github.io/SketchyBar/config/tricks#color-picker

      sketchybar --bar position=top y_offset=4 height=40 color=0x00000000

      ##### Changing Defaults #####
      # We now change some default values, which are applied to all further items.
      # For a full list of all available item properties see:
      # https://felixkratz.github.io/SketchyBar/config/items

      ##### Adding Mission Control Space Indicators #####
      # Let's add some mission control spaces:
      # https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item
      # to indicate active and available mission control spaces.

      source "$PLUGIN_DIR/items.sh"

      ##### Adding Left Items #####
      # We add some regular items to the left side of the bar, where
      # only the properties deviating from the current defaults need to be set

      sketchybar --default padding_left=8                                    \
                           padding_right=8                                   \
                                                                             \
                           background.border_color=$COLOR_BORDER       \
                           background.border_width=2                         \
                           background.height=40                              \
                           background.corner_radius=12                       \
                                                                             \
                           icon.color=$COLOR_FONT                           \
                           icon.highlight_color=$COLOR_BACKGROUND            \
                           icon.padding_left=2                               \
                           icon.padding_right=2                              \
                           icon.font="$NERD_FONT:Regular:14.0"               \
                           label.color=$COLOR_FONT                         \
                           label.highlight_color=$COLOR_BACKGROUND           \
                           label.padding_left=2                              \
                           label.padding_right=2                             \
                           label.font="$NERD_FONT:Regular:14.0"

      # Register custom event - this will be use by sketchybar's space items as well as app_space.sh
      sketchybar --add event window_change

      # Space items
      COLORS_SPACE=($COLOR_YELLOW $COLOR_CYAN $COLOR_MAGENTA $COLOR_WHITE $COLOR_BLUE $COLOR_RED $COLOR_GREEN $COLOR_YELLOW $COLOR_CYAN)
      LENGTH=''${#ICONS_SPACE[@]}

      for i in "''${!ICONS_SPACE[@]}"
      do
        sid=$(($i+1))
        PAD_LEFT=2
        PAD_RIGHT=3
        if [[ $i == 0 ]]; then
          PAD_LEFT=8
        elif [[ $i == $(($LENGTH-1)) ]]; then
          PAD_RIGHT=12
        fi
        sketchybar --add space space.$sid left                                       \
                   --set       space.$sid script="$PLUGIN_DIR/app_space.sh"          \
                                          associated_space=$sid                      \
                                          padding_left=$PAD_LEFT                     \
                                          padding_right=$PAD_RIGHT                   \
                                          background.color=''${COLORS_SPACE[i]}        \
                                          background.border_width=0                  \
                                          background.corner_radius=8                 \
                                          background.height=24                       \
                                          icon=''${ICONS_SPACE[i]}                     \
                                          icon.color=''${COLORS_SPACE[i]}              \
                                          icon.font="CaskaydiaCove Nerd Font:Regular:23.0"  \
                                          label="_"                                  \
                                          label.color=''${COLORS_SPACE[i]}             \
                                          click_script="yabai -m space --focus  $sid" \
                   --subscribe space.$sid front_app_switched window_change
      done

      # Space bracket
      sketchybar --add bracket spaces '/space\..*/'                      \
                 --set         spaces background.color=$COLOR_BACKGROUND

      ##### Adding Right Items #####
      # In the same way as the left items we can add items to the right side.
      # Additional position (e.g. center) are available, see:
      # https://felixkratz.github.io/SketchyBar/config/items#adding-items-to-sketchybar

      # Some items refresh on a fixed cycle, e.g. the clock runs its script once
      # every 10s. Other items respond to events they subscribe to, e.g. the
      # volume.sh script is only executed once an actual change in system audio
      # volume is registered. More info about the event system can be found here:
      # https://felixkratz.github.io/SketchyBar/config/events

      render_items

      sketchybar --add bracket right_items.bracket '/right_items\..*/'                      \
                --set         right_items.bracket background.color=$COLOR_BACKGROUND

      ##### Force all scripts to run the first time (never do this in a script) #####
      sketchybar --update
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/items.sh" = {
    text = ''
      #!/usr/bin/env bash
      render_items() {
        PLUGIN_DIR="${config.home.homeDirectory}/.config/sketchybar/plugins"

        source "$PLUGIN_DIR/assets/colors.sh"
        source "$PLUGIN_DIR/assets/icons.sh"

        NERD_FONT="Hack Nerd Font Mono"

        sketchybar --add item right_items.clock right \
                  --set right_items.clock update_freq=10 \
                                icon=󰥔  \
                                script="$PLUGIN_DIR/clock.sh" \
                                click_script="open -a Calendar"

          sketchybar --add item right_items.battery right \
                    --set right_items.battery update_freq=120 \
                                  script="$PLUGIN_DIR/battery.sh" \
                                  icon=$ \
                                  click_script="pmset -g batt | awk 'NR==2 {print $0}' | osascript -e 'display notification \"'$(cat -)'\" with title \"Batterie\"'" \
                    --subscribe right_items.battery system_woke power_source_change

          sketchybar --add item right_items.volume right \
                    --set right_items.volume script="$PLUGIN_DIR/volume.sh" \
                                  icon=󰕾 \
                                  click_script="open -a 'System Settings' && sleep 0.5 && osascript -e 'tell application \"System Settings\" to reveal pane id \"com.apple.preference.sound\"'" \
                    --subscribe right_items.volume volume_change

        # CPU
        sketchybar --add item right_items.cpu_percent right \
          --set right_items.cpu_percent label=CPU% icon="$CPU" update_freq=15 mach_helper="$HELPER" script="$PLUGIN_DIR/stats/scripts/cpu.sh"

        # Memory
        sketchybar --add item right_items.memory right \
          --set right_items.memory icon="$MEMORY" update_freq=15 script="$PLUGIN_DIR/stats/scripts/ram.sh"

        # Disk (commented out as before)
        #sketchybar --add item disk right \
        #  --set disk icon="$DISK" update_freq=60 script="$PLUGIN_DIR/stats/scripts/disk.sh"

        # Network UP and Down
        sketchybar --add item right_items.network.down right \
          --set right_items.network.down y_offset=-7 label.font="$FONT:Heavy:14" icon="$NETWORK_DOWN" icon.font="$NERD_FONT:Bold:18.0" icon.highlight_color="$BLUE" update_freq=1 script="$PLUGIN_DIR/stats/scripts/network.sh" \
          --add item right_items.network.up right \
          --set right_items.network.up background.padding_right=-65 y_offset=7 label.font="$FONT:Heavy:14" icon="$NETWORK_UP" icon.font="$NERD_FONT:Bold:18.0" icon.highlight_color="$BLUE" update_freq=1 script="$PLUGIN_DIR/stats/scripts/network.sh"

        # Network Ping
        sketchybar --add item right_items.network_ping right \
          --set right_items.network_ping icon="$ICON_CIRCLE" update_freq=10 script="$PLUGIN_DIR/stats/scripts/ping.sh"

        sketchybar 	--add event 				hide_stats   					                                      \
                    --add event 				show_stats 					                                        \
                    --add event 				toggle_stats 					                                      \
                                                                                                    \
                    --add item         	right_items.animator right                									\
                    --set right_items.animator     	drawing=off                  									  \
                                        updates=on                   									              \
                                        script="$PLUGIN_DIR/toggle_stats.sh"                        \
                    --subscribe        	right_items.animator hide_stats show_stats toggle_stats

      }

    '';
    executable = true;
  };

  # Colors configuration
  home.file.".config/sketchybar/plugins/assets/colors.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Color Palette (from nix-colors)
      export COLOR_BACKGROUND=${color_background}
      export COLOR_FOREGROUND=${color_foreground}
      export COLOR_FONT=${color_font}
      export COLOR_BORDER=${color_border}
      export COLOR_RED=${color_red}
      export COLOR_GREEN=${color_green}
      export COLOR_BLUE=${color_blue}
      export COLOR_YELLOW=${color_yellow}
      export COLOR_ORANGE=${color_orange}
      export COLOR_PURPLE=${color_purple}
      export COLOR_PINK=${color_pink}
      export COLOR_TEAL=${color_teal}
    '';
    executable = true;
  };

  # Icons configuration
  home.file.".config/sketchybar/plugins/assets/icons.sh" = {
    text = ''
      #!/usr/bin/env bash

      export BATTERY=
      export CPU=
      export DISK=󰋊
      export MEMORY=﬙
      export NETWORK=
      export NETWORK_DOWN=
      export NETWORK_UP=

      # Material Design Icons

      export ICON_CMD=󰘳
      export ICON_COG=󰒓 # system settings, system information, tinkertool
      export ICON_CHART=󱕍 # activity monitor, btop
      export ICON_LOCK=󰌾

      export ICONS_SPACE=(󰎤 󰎧 󰎪 󰎭 󰎱 󰎳 󰎶 󰎹 󰎼)

      export ICON_APP=󰣆 # fallback ap
      export ICON_TERM=󰆍 # fallback terminal app, terminal, warp, iterm2
      export ICON_PACKAGE=󰏓 # brew
      export ICON_DEV=󰅨 # nvim, xcode, vscode
      export ICON_FILE=󰉋 # ranger, finder
      export ICON_GIT=󰊢 # lazygit
      export ICON_LIST=󱃔 # taskwarrior, taskwarrior-tui, reminders, onenote
      export ICON_SCREENSAVOR=󱄄 # unimatrix, pipe.sh

      export ICON_WEATHER=󰖕 # weather
      export ICON_MAIL=󰇮 # mail, outlook
      export ICON_CALC=󰪚 # calculator, numi
      export ICON_MAP=󰆋 # maps, find my
      export ICON_MICROPHONE=󰍬 # voice memos
      export ICON_CHAT=󰍩 # messages, slack, teams, discord, telegram
      export ICON_VIDEOCHAT=󰍫 # facetime, zoom, webex
      export ICON_NOTE=󱞎 # notes, textedit, stickies, word, bat
      export ICON_CAMERA=󰄀 # photo booth
      export ICON_WEB=󰇧 # safari, beam, duckduckgo, arc, edge, chrome, firefox
      export ICON_HOMEAUTOMATION=󱉑 # home
      export ICON_MUSIC=󰎄 # music, spotify
      export ICON_PODCAST=󰦔 # podcasts
      export ICON_PLAY=󱉺 # tv, quicktime, vlc
      export ICON_BOOK=󰂿 # books
      export ICON_BOOKINFO=󱁯 # font book, dictionary
      export ICON_PREVIEW=󰋲 # screenshot, preview
      export ICON_PASSKEY=󰷡 # 1password
      export ICON_DOWNLOAD=󱑢 # progressive downloader, transmission
      export ICON_CAST=󱒃 # airflow
      export ICON_TABLE=󰓫 # excel
      export ICON_PRESENT=󰈩 # powerpoint
      export ICON_CLOUD=󰅧 # onedrive
      export ICON_PEN=󰏬 # curve
      export ICON_REMOTEDESKTOP=󰢹 # vmware, utm

      export ICON_CLOCK=󰥔 # clock, timewarrior, tty-clock
      export ICON_CALENDAR=󰃭 # calendar

      export ICON_WIFI=󰖩
      export ICON_WIFI_OFF=󰖪
      export ICON_VPN=󰦝 # vpn, nordvpn

      export ICONS_VOLUME=(󰸈 󰕿 󰖀 󰕾)

      export ICONS_BATTERY=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
      export ICONS_BATTERY_CHARGING=(󰢟 󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)

      export ICON_SWAP=󰁯
      export ICON_RAM=󰓅
      export ICON_DISK=󰋊 # disk utility
      export ICON_CPU=󰘚

      export ICON_DBEAVER=
      export ICON_POSTMAN=

      export ICON_CIRCLE=

    '';
    executable = true;
  };

  # Simple clock plugin
  home.file.".config/sketchybar/plugins/clock.sh" = {
    text = ''
      #!/usr/bin/env bash

      sketchybar --set $NAME label="$(date '+%a %d %b %H:%M')"
    '';
    executable = true;
  };

  # Simple battery plugin
  home.file.".config/sketchybar/plugins/battery.sh" = {
    text = ''
        #!/usr/bin/env bash

      source ${config.home.homeDirectory}/.config/sketchybar/plugins/assets/icons.sh

      PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
      CHARGING="$(pmset -g batt | grep 'AC Power')"

      if [ -z "$PERCENTAGE" ]; then
        exit 0
      fi

      INDEX=$(( PERCENTAGE / 10 ))

      if [[ -n "$CHARGING" ]]; then
        ICON="''${ICONS_BATTERY_CHARGING[$INDEX]}"
      else
        ICON="''${ICONS_BATTERY[$INDEX]}"
      fi


      sketchybar --set "$NAME" icon="$ICON" label="''${PERCENTAGE}%"
    '';
    executable = true;
  };

  # Simple volume plugin
  home.file.".config/sketchybar/plugins/volume.sh" = {
    text = ''
      #!/usr/bin/env bash

      if [ "$SENDER" = "volume_change" ]; then
        VOLUME="$INFO"

        case "$VOLUME" in
          [6-9][0-9]|100) ICON="󰕾"
          ;;
          [3-5][0-9]) ICON="󰖀"
          ;;
          [1-9]|[1-2][0-9]) ICON="󰕿"
          ;;
          *) ICON="󰖁"
        esac

        sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%"
      fi
    '';
    executable = true;
  };

  # Simple space plugin
  home.file.".config/sketchybar/plugins/space.sh" = {
    text = ''
      #!/usr/bin/env bash

      update() {
        if [ "$SELECTED" = "true" ]; then
          sketchybar --set $NAME background.drawing=on \
                               background.color=$COLOR_BLUE \
                               label.color=$COLOR_BACKGROUND \
                               icon.color=$COLOR_BACKGROUND
        else
          sketchybar --set $NAME background.drawing=off \
                               label.color=$COLOR_FONT \
                               icon.color=$COLOR_FONT
        fi
      }

      case "$SENDER" in
        "routine"|"forced") update
        ;;
      esac
    '';
    executable = true;
  };

  # --- Additional Sketchybar files from env ---

  home.file.".config/sketchybar/plugins/app_space.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Define the plugin directory with absolute path
      PLUGIN_DIR="${config.home.homeDirectory}/.config/sketchybar/plugins"
      source "$PLUGIN_DIR/assets/icons.sh"
      source "$PLUGIN_DIR/assets/app_icons.sh"

      get_notifications() {
        local app_name="$1"
        local count=0
        # Special case for Slack: Read the Dock badge using AppleScript
        if [[ "$app_name" == "Slack" ]]; then
          count=$(yabai -m query --windows | jq -r '.[] | select(.app == "Slack") | .title' | grep -oE '([0-9]+) new item' | grep -oE '[0-9]+' || echo "0")
        else
          # For other apps, use lsappinfo to get the notification count
          count=$(lsappinfo info -only Notifications "$app_name" 2>/dev/null | grep -Eo '"badgeCount"=[0-9]+' | cut -d= -f2)
        fi
        # Return 0 if count is empty
        echo "''${count:-0}"
      }

      # The $SELECTED variable is available for space components and indicates if
      # the space invoking this script (with name: $NAME) is currently selected:
      # https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

      sketchybar --set $NAME background.drawing=$SELECTED \
      	icon.highlight=$SELECTED \
      	label.highlight=$SELECTED

      if [[ $SENDER == "front_app_switched" || $SENDER == "window_change" ]];
      then
       for i in "''${!ICONS_SPACE[@]}"
       do
         sid=$(($i+1))
         LABEL=""
         QUERY=$(yabai -m query --windows --space $sid)
         APPS=$(echo $QUERY | jq '.[].app')
         TITLES=$(echo $QUERY | jq '.[].title')
         if grep -q "\"" <<< $APPS;
         then
           APPS_ARR=()
           while read -r line; do APPS_ARR+=("$line"); done <<< "$APPS"
           TITLES_ARR=()
           while read -r line; do TITLES_ARR+=("$line"); done <<< "$TITLES"
           LENGTH=''${#APPS_ARR[@]}
           for j in "''${!APPS_ARR[@]}"
           do
             APP=$(echo ''${APPS_ARR[j]} | sed 's/"//g')
             TITLE=$(echo ''${TITLES_ARR[j]} | sed 's/"//g')
              if [[ -z "$TITLE" ]]; then
                continue
              fi
             ICON=$(get_icon "$APP" "$TITLE")
             NOTIF_COUNT=$(get_notifications "$APP")
              if [[ "$NOTIF_COUNT" -gt 0 ]]; then
                ICON+=" ($NOTIF_COUNT)"
              fi
             LABEL+="$ICON"
             if [[ $j < $(($LENGTH-1)) ]]; then
               LABEL+=" "
             fi
           done
         else
           LABEL+="_"
         fi
         sketchybar --set space.$sid label="$LABEL"
       done
      fi
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/front_app.sh" = {
    text = ''
      #!/bin/sh

      # Some events send additional information specific to the event in the $INFO
      # variable. E.g. the front_app_switched event sends the name of the newly
      # focused application in the $INFO variable:
      # https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

      if [ "$SENDER" = "front_app_switched" ]; then
        sketchybar --set "$NAME" label="$INFO"
      fi
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/toggle_stats.sh" = {
    text = ''
      #!/usr/bin/env bash

      stats="cpu.percent memory disk network"

      hide_stats() {
          args=()
          for item in $stats; do
              args+=(--set "$item" drawing=off)
          done

          sketchybar "$item" \
              --set separator_right \
              icon=
      }

      show_stats() {
          args=()
          for item in $stats; do
              args+=(--set "$item" drawing=on)
          done

          sketchybar "$item" \
              --set separator_right \
              icon=
      }

      toggle_stats() {
          state=$(sketchybar --query separator_right | jq -r .icon.value)

          case $state in
          "")
              show_stats
              ;;
          "")
              hide_stats
              ;;
          esac
      }
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/assets/app_icons.sh" = {
    text = ''
            #!/usr/bin/env bash

            source "${config.home.homeDirectory}/.config/sketchybar/plugins/assets/icons.sh"

            get_icon() {
        local app_name="$1"
        local window_title="$2"

        case "$app_name" in
          "Terminal" | "Warp" | "iTerm2")
            local icon="$ICON_TERM"
            [[ "$window_title" =~ "btop" ]] && icon="$ICON_CHART"
            [[ "$window_title" =~ "brew" ]] && icon="$ICON_PACKAGE"
            [[ "$window_title" =~ "nvim" ]] && icon="$ICON_DEV"
            [[ "$window_title" =~ "ranger" ]] && icon="$ICON_FILE"
            [[ "$window_title" =~ "lazygit" ]] && icon="$ICON_GIT"
            [[ "$window_title" =~ "taskwarrior-tui" ]] && icon="$ICON_LIST"
            [[ "$window_title" =~ "unimatrix|pipes.sh" ]] && icon="$ICON_SCREENSAVOR"
            [[ "$window_title" =~ "bat" ]] && icon="$ICON_NOTE"
            [[ "$window_title" =~ "tty-clock" ]] && icon="$ICON_CLOCK"
            echo "$icon"
            return
            ;;
          "Finder") echo "$ICON_FILE" ;;
          "Weather") echo "$ICON_WEATHER" ;;
          "Clock") echo "$ICON_CLOCK" ;;
          "Mail" | "Microsoft Outlook") echo "$ICON_MAIL" ;;
          "Calendar") echo "$ICON_CALENDAR" ;;
          "Calculator" | "Numi") echo "$ICON_CALC" ;;
          "Maps" | "Find My") echo "$ICON_MAP" ;;
          "Voice Memos") echo "$ICON_MICROPHONE" ;;
          "Messages" | "Slack" | "Microsoft Teams" | "Discord" | "Telegram") echo "$ICON_CHAT" ;;
          "FaceTime" | "zoom.us" | "Webex" | "OBS Studio") echo "$ICON_VIDEOCHAT" ;;
          "Notes" | "TextEdit" | "Stickies" | "Microsoft Word" | "Linear") echo "$ICON_NOTE" ;;
          "Reminders" | "Microsoft OneNote") echo "$ICON_LIST" ;;
          "Photo Booth") echo "$ICON_CAMERA" ;;
          "Safari" | "Beam" | "DuckDuckGo" | "Arc" | "Microsoft Edge" | "Google Chrome" | "Firefox") echo "$ICON_WEB" ;;
          "System Settings" | "System Information" | "TinkerTool") echo "$ICON_COG" ;;
          "HOME") echo "$ICON_HOMEAUTOMATION" ;;
          "Music" | "Spotify") echo "$ICON_MUSIC" ;;
          "Podcasts") echo "$ICON_PODCAST" ;;
          "TV" | "QuickTime Player" | "VLC") echo "$ICON_PLAY" ;;
          "Books") echo "$ICON_BOOK" ;;
          "Xcode" | "Code" | "GoLand" | "Cursor") echo "$ICON_DEV" ;;
          "Font Book" | "Dictionary") echo "$ICON_BOOKINFO" ;;
          "Activity Monitor") echo "$ICON_CHART" ;;
          "Disk Utility") echo "$ICON_DISK" ;;
          "Screenshot" | "Preview") echo "$ICON_PREVIEW" ;;
          "1Password") echo "$ICON_PASSKEY" ;;
          "NordVPN") echo "$ICON_VPN" ;;
          "Progressive Downloaded" | "Transmission") echo "$ICON_DOWNLOAD" ;;
          "Airflow") echo "$ICON_CAST" ;;
          "Microsoft Excel") echo "$ICON_TABLE" ;;
          "Microsoft PowerPoint") echo "$ICON_PRESENT" ;;
          "OneDrive") echo "$ICON_CLOUD" ;;
          "Curve") echo "$ICON_PEN" ;;
          "DBeaver") echo "$ICON_DBEAVER" ;;
          "Postman") echo "$ICON_POSTMAN" ;;
          "VMware Fusion" | "UTM") echo "$ICON_REMOTEDESKTOP" ;;
          *) echo "$ICON_APP" ;;
        esac
      }
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/stats/scripts/cpu.sh" = {
    text = ''
      #!/usr/bin/env bash
      #$PLUGIN_DIR/stats/scripts/cpu.sh

      # Get CPU usage (user + sys) in percent, fallback to 0 if not found
      CPU_LINE=$(top -l 2 | grep -E "^CPU" | tail -1)
      USER=$(echo "$CPU_LINE" | awk '{print $3}' | tr -d '%us,')
      SYS=$(echo "$CPU_LINE" | awk '{print $5}' | tr -d '%sy,')
      if [ -z "$USER" ]; then USER=0; fi
      if [ -z "$SYS" ]; then SYS=0; fi
      USER_INT=$(printf '%.0f' "$USER")
      SYS_INT=$(printf '%.0f' "$SYS")
      CPU_USAGE=$((USER_INT + SYS_INT))
      sketchybar -m --set "$NAME" label="$CPU_USAGE%"
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/stats/scripts/disk.sh" = {
    text = ''
      #!/usr/bin/env bash
      #disk.sh

      sketchybar -m --set "$NAME" label="$(df -H | grep -E '^(/dev/disk3s5).' | awk '{ printf (\"%s\\n\", $5) }')"
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/stats/scripts/network.sh" = {
    text = ''
        #!/usr/bin/env bash

      UPDOWN=$(ifstat -i "en0" -b 0.1 1 | tail -n1)
      DOWN=$(echo "$UPDOWN" | awk "{ print \$1 }" | cut -f1 -d ".")
      UP=$(echo "$UPDOWN" | awk "{ print \$2 }" | cut -f1 -d ".")

      DOWN_FORMAT=""
      if [ "$DOWN" -gt "999" ]; then
      	DOWN_FORMAT=$(echo "$DOWN" | awk '{ printf "%03.0f Mbps", $1 / 1000}')
      else
      	DOWN_FORMAT=$(echo "$DOWN" | awk '{ printf "%03.0f kbps", $1}')
      fi

      UP_FORMAT=""
      if [ "$UP" -gt "999" ]; then
      	UP_FORMAT=$(echo "$UP" | awk '{ printf "%03.0f Mbps", $1 / 1000}')
      else
      	UP_FORMAT=$(echo "$UP" | awk '{ printf "%03.0f kbps", $1}')
      fi

      sketchybar -m --set right_items.network.down label="$DOWN_FORMAT" \
      --set right_items.network.up label="$UP_FORMAT"
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/stats/scripts/ping.sh" = {
    text = ''
      #!/usr/bin/env bash

      source ${config.home.homeDirectory}/.config/sketchybar/plugins/assets/icons.sh
      source ${config.home.homeDirectory}/.config/sketchybar/plugins/assets/colors.sh

      PING=$(ping -c 1 google.com | awk -F'=' '/time=/{print int($NF)}')
      COLOR=$COLOR_FONT

      if [ $PING -lt 1 ]; then
        PING=$ICON_WIFI_OFF
        COLOR=$COLOR_RED_BRIGHT
      fi

      if [ $PING -gt 50 ]; then
        COLOR=$COLOR_YELLOW_BRIGHT
      fi

      if [ $PING -gt 100 ]; then
        COLOR=$COLOR_RED_BRIGHT
      fi


      sketchybar --set right_items.network_ping icon.color="$COLOR" label.color="$COLOR" label="''${PING}ms"
    '';
    executable = true;
  };

  home.file.".config/sketchybar/plugins/stats/scripts/ram.sh" = {
    text = ''
      #!/usr/bin/env bash
      #ram.sh

      # Get free memory percent, fallback to 0 if not found
      FREE=$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage:" | awk '{print $5}' | tr -d '%')
      if [ -z "$FREE" ]; then FREE=0; fi
      USED=$((100 - FREE))
      sketchybar -m --set "$NAME" label="$USED%"
    '';
    executable = true;
  };
}
