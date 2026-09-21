{
  config,
  pkgs,
  lib,
  ...
}:

let
  palette = config.colorScheme.palette;
  toHex = c: "0xff${c}";
  # Catppuccin naming on top of the base16 slots exposed by nix-colors
  color_base = toHex palette.base00;
  color_pill = "0xf0${palette.base00}"; # ~94% opaque pills
  color_mantle = toHex palette.base01;
  color_surface0 = toHex palette.base02;
  color_surface1 = toHex palette.base03;
  color_surface2 = toHex palette.base04;
  color_text = toHex palette.base05;
  color_lavender = toHex palette.base07;
  color_red = toHex palette.base08;
  color_peach = toHex palette.base09;
  color_yellow = toHex palette.base0A;
  color_green = toHex palette.base0B;
  color_teal = toHex palette.base0C;
  color_blue = toHex palette.base0D;
  color_mauve = toHex palette.base0E;
  color_flamingo = toHex palette.base0F;

  configDir = "${config.home.homeDirectory}/.config/sketchybar";
  pluginDir = "${configDir}/plugins";

  sketchybar = "${pkgs.sketchybar}/bin/sketchybar";
  aerospace = "${pkgs.aerospace}/bin/aerospace";
  iconMap = "${pkgs.sketchybar-app-font}/bin/icon_map.sh";

  nerdFont = "Hack Nerd Font Mono";
  labelFont = "Hack Nerd Font";
  appFont = "sketchybar-app-font";

  # Must match the workspaces declared in aerospace.nix
  workspaces = [
    {
      name = "social";
      icon = "󰍩";
    }
    {
      name = "spec";
      icon = "󱃔";
    }
    {
      name = "obs";
      icon = "󰄀";
    }
    {
      name = "code";
      icon = "󰅨";
    }
    {
      name = "notes";
      icon = "󱞎";
    }
    {
      name = "perso";
      icon = "󰋜";
    }
    {
      name = "browser";
      icon = "󰇧";
    }
    {
      name = "terminal";
      icon = "󰆍";
    }
    {
      name = "db";
      icon = "󰆼";
    }
    {
      name = "claude";
      icon = "󱚝";
    }
  ];

  workspaceItems = lib.concatMapStringsSep "\n" (ws: ''
    sketchybar --add item space.${ws.name} left \
               --set space.${ws.name} icon="${ws.icon}" \
                                      icon.color=$COLOR_SURFACE2 \
                                      icon.padding_left=8 \
                                      icon.padding_right=2 \
                                      label="" \
                                      label.font="${appFont}:Regular:15.0" \
                                      label.color=$COLOR_SURFACE2 \
                                      label.padding_left=2 \
                                      label.padding_right=8 \
                                      label.y_offset=-1 \
                                      padding_left=2 \
                                      padding_right=2 \
                                      background.drawing=off \
                                      background.color=$COLOR_SURFACE0 \
                                      background.border_width=0 \
                                      background.corner_radius=8 \
                                      background.height=22 \
                                      drawing=off \
                                      click_script="${aerospace} workspace ${ws.name}"
  '') workspaces;

  workspaceNames = lib.concatMapStringsSep " " (ws: ws.name) workspaces;

  colorsSh = ''
    #!/usr/bin/env bash
    # Catppuccin palette (from nix-colors)
    export COLOR_BASE=${color_base}
    export COLOR_PILL=${color_pill}
    export COLOR_MANTLE=${color_mantle}
    export COLOR_SURFACE0=${color_surface0}
    export COLOR_SURFACE1=${color_surface1}
    export COLOR_SURFACE2=${color_surface2}
    export COLOR_TEXT=${color_text}
    export COLOR_LAVENDER=${color_lavender}
    export COLOR_RED=${color_red}
    export COLOR_PEACH=${color_peach}
    export COLOR_YELLOW=${color_yellow}
    export COLOR_GREEN=${color_green}
    export COLOR_TEAL=${color_teal}
    export COLOR_BLUE=${color_blue}
    export COLOR_MAUVE=${color_mauve}
    export COLOR_FLAMINGO=${color_flamingo}
  '';

  iconsSh = ''
    #!/usr/bin/env bash
    # Nerd Font glyphs used by the bar

    export ICON_APPLE=
    export ICON_CLOCK=󰥔
    export ICON_CPU=󰘚
    export ICON_RAM=󰓅
    export ICON_WIFI=󰖩
    export ICON_WIFI_OFF=󰖪
    export ICON_MUSIC=󰎄
    export ICON_PAUSE=󰏤

    export ICONS_VOLUME=(󰸈 󰕿 󰖀 󰕾)

    export ICONS_BATTERY=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
    export ICONS_BATTERY_CHARGING=(󰢟 󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
  '';

  mkScript = text: {
    inherit text;
    executable = true;
  };
in
{
  home.file.".config/sketchybar/sketchybarrc" = mkScript ''
    #!/usr/bin/env bash
    # SketchyBar — Catppuccin Mocha, AeroSpace workspaces

    PLUGIN_DIR="${pluginDir}"
    source "$PLUGIN_DIR/assets/colors.sh"
    source "$PLUGIN_DIR/assets/icons.sh"

    ##### Bar #####
    sketchybar --bar position=top \
                     height=34 \
                     y_offset=6 \
                     margin=14 \
                     padding_left=8 \
                     padding_right=8 \
                     color=0x00000000 \
                     sticky=on \
                     topmost=window

    ##### Defaults #####
    sketchybar --default padding_left=4 \
                         padding_right=4 \
                         background.color=$COLOR_PILL \
                         background.border_color=$COLOR_SURFACE1 \
                         background.border_width=1 \
                         background.corner_radius=10 \
                         background.height=28 \
                         icon.font="${nerdFont}:Regular:15.0" \
                         icon.color=$COLOR_TEXT \
                         icon.padding_left=8 \
                         icon.padding_right=4 \
                         label.font="${labelFont}:Bold:13.0" \
                         label.color=$COLOR_TEXT \
                         label.padding_left=4 \
                         label.padding_right=8

    ##### Events #####
    sketchybar --add event aerospace_workspace_change

    ##### Left: Apple logo #####
    sketchybar --add item apple left \
               --set apple icon="$ICON_APPLE" \
                           icon.font="${nerdFont}:Regular:18.0" \
                           icon.color=$COLOR_LAVENDER \
                           icon.padding_left=10 \
                           icon.padding_right=10 \
                           label.drawing=off \
                           click_script="open -a 'System Settings'"

    ##### Left: AeroSpace workspaces #####
    ${workspaceItems}

    sketchybar --add bracket spaces '/space\..*/' \
               --set spaces background.color=$COLOR_PILL \
                            background.border_color=$COLOR_SURFACE1 \
                            background.border_width=1 \
                            background.corner_radius=10 \
                            background.height=28

    # Single controller item: refreshes every workspace in one batched call
    sketchybar --add item space_controller left \
               --set space_controller drawing=off \
                                      updates=on \
                                      script="$PLUGIN_DIR/aerospace.sh" \
               --subscribe space_controller aerospace_workspace_change \
                                            front_app_switched \
                                            display_change \
                                            system_woke

    ##### Left: front app #####
    sketchybar --add item front_app left \
               --set front_app icon.font="${appFont}:Regular:15.0" \
                               icon.color=$COLOR_BLUE \
                               icon.y_offset=-1 \
                               label.color=$COLOR_TEXT \
                               script="$PLUGIN_DIR/front_app.sh" \
               --subscribe front_app front_app_switched

    ##### Right: clock #####
    sketchybar --add item clock right \
               --set clock icon="$ICON_CLOCK" \
                           icon.color=$COLOR_BLUE \
                           update_freq=20 \
                           script="$PLUGIN_DIR/clock.sh" \
                           click_script="open -a Calendar"

    ##### Right: status (battery, volume, wifi) #####
    sketchybar --add item battery right \
               --set battery update_freq=120 \
                             background.drawing=off \
                             script="$PLUGIN_DIR/battery.sh" \
               --subscribe battery system_woke power_source_change

    sketchybar --add item volume right \
               --set volume background.drawing=off \
                            script="$PLUGIN_DIR/volume.sh" \
                            click_script="/usr/bin/osascript -e 'set volume output muted not (output muted of (get volume settings))' && $PLUGIN_DIR/volume.sh" \
               --subscribe volume volume_change

    sketchybar --add item wifi right \
               --set wifi update_freq=2 \
                          background.drawing=off \
                          script="$PLUGIN_DIR/wifi.sh" \
                          click_script="open x-apple.systempreferences:com.apple.wifi-settings-extension" \
               --subscribe wifi wifi_change system_woke

    sketchybar --add bracket status wifi volume battery \
               --set status background.color=$COLOR_PILL \
                            background.border_color=$COLOR_SURFACE1 \
                            background.border_width=1 \
                            background.corner_radius=10 \
                            background.height=28

    ##### Right: stats (cpu, ram) #####
    sketchybar --add item ram right \
               --set ram icon="$ICON_RAM" \
                         update_freq=10 \
                         background.drawing=off \
                         script="$PLUGIN_DIR/ram.sh"

    sketchybar --add item cpu right \
               --set cpu icon="$ICON_CPU" \
                         update_freq=5 \
                         background.drawing=off \
                         script="$PLUGIN_DIR/cpu.sh" \
                         click_script="open -a 'Activity Monitor'"

    sketchybar --add bracket stats cpu ram \
               --set stats background.color=$COLOR_PILL \
                           background.border_color=$COLOR_SURFACE1 \
                           background.border_width=1 \
                           background.corner_radius=10 \
                           background.height=28

    ##### Right: now playing #####
    sketchybar --add item media right \
               --set media drawing=off \
                           icon="$ICON_MUSIC" \
                           icon.color=$COLOR_FLAMINGO \
                           label.max_chars=32 \
                           scroll_texts=on \
                           update_freq=5 \
                           script="$PLUGIN_DIR/media.sh" \
                           click_script="$PLUGIN_DIR/media.sh toggle"

    ##### Initial render #####
    sketchybar --update
  '';

  home.file.".config/sketchybar/plugins/assets/colors.sh" = mkScript colorsSh;
  home.file.".config/sketchybar/plugins/assets/icons.sh" = mkScript iconsSh;

  # Refresh every AeroSpace workspace item in one batched sketchybar call
  home.file.".config/sketchybar/plugins/aerospace.sh" = mkScript ''
    #!/usr/bin/env bash
    source "${pluginDir}/assets/colors.sh"
    source "${iconMap}"

    WORKSPACES="${workspaceNames}"
    FOCUSED="$(${aerospace} list-workspaces --focused 2>/dev/null)"
    MONITORS="$(${aerospace} list-workspaces --all --format '%{workspace} %{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)"

    args=()
    for ws in $WORKSPACES; do
      label=""
      while IFS= read -r app; do
        [ -z "$app" ] && continue
        __icon_map "$app"
        label+="$icon_result"
      done < <(${aerospace} list-windows --workspace "$ws" --format '%{app-name}' 2>/dev/null | sort -u)

      display="$(awk -v ws="$ws" '$1 == ws { print $2 }' <<< "$MONITORS")"
      [ -n "$display" ] && args+=(--set "space.$ws" display="$display")

      if [ "$ws" = "$FOCUSED" ]; then
        args+=(--set "space.$ws" drawing=on \
                                  label="$label" \
                                  background.drawing=on \
                                  icon.color=$COLOR_MAUVE \
                                  label.color=$COLOR_TEXT)
      elif [ -n "$label" ]; then
        args+=(--set "space.$ws" drawing=on \
                                  label="$label" \
                                  background.drawing=off \
                                  icon.color=$COLOR_SURFACE2 \
                                  label.color=$COLOR_SURFACE2)
      else
        args+=(--set "space.$ws" drawing=off)
      fi
    done

    ${sketchybar} "''${args[@]}"
  '';

  home.file.".config/sketchybar/plugins/front_app.sh" = mkScript ''
    #!/usr/bin/env bash
    source "${iconMap}"

    if [ "$SENDER" = "front_app_switched" ]; then
      __icon_map "$INFO"
      ${sketchybar} --set "$NAME" icon="$icon_result" label="$INFO"
    fi
  '';

  home.file.".config/sketchybar/plugins/clock.sh" = mkScript ''
    #!/usr/bin/env bash
    ${sketchybar} --set "$NAME" label="$(LC_ALL=fr_FR.UTF-8 /bin/date '+%a %d %b  %H:%M')"
  '';

  home.file.".config/sketchybar/plugins/battery.sh" = mkScript ''
    #!/usr/bin/env bash
    source "${pluginDir}/assets/colors.sh"
    source "${pluginDir}/assets/icons.sh"

    BATT="$(/usr/bin/pmset -g batt)"
    PERCENTAGE="$(grep -Eo '[0-9]+%' <<< "$BATT" | head -1 | tr -d '%')"
    CHARGING="$(grep 'AC Power' <<< "$BATT")"

    if [ -z "$PERCENTAGE" ]; then
      ${sketchybar} --set "$NAME" drawing=off
      exit 0
    fi

    INDEX=$(( PERCENTAGE / 10 ))
    COLOR=$COLOR_TEXT

    if [ -n "$CHARGING" ]; then
      ICON="''${ICONS_BATTERY_CHARGING[$INDEX]}"
      COLOR=$COLOR_GREEN
    else
      ICON="''${ICONS_BATTERY[$INDEX]}"
      if [ "$PERCENTAGE" -le 20 ]; then
        COLOR=$COLOR_RED
      elif [ "$PERCENTAGE" -le 40 ]; then
        COLOR=$COLOR_PEACH
      fi
    fi

    ${sketchybar} --set "$NAME" drawing=on icon="$ICON" icon.color="$COLOR" label="$PERCENTAGE%"
  '';

  home.file.".config/sketchybar/plugins/volume.sh" = mkScript ''
    #!/usr/bin/env bash
    source "${pluginDir}/assets/colors.sh"
    source "${pluginDir}/assets/icons.sh"

    if [ "$SENDER" = "volume_change" ]; then
      VOLUME="$INFO"
    else
      VOLUME="$(/usr/bin/osascript -e 'output volume of (get volume settings)')"
    fi
    MUTED="$(/usr/bin/osascript -e 'output muted of (get volume settings)')"

    COLOR=$COLOR_TEXT
    if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
      ICON="''${ICONS_VOLUME[0]}"
      COLOR=$COLOR_SURFACE2
    elif [ "$VOLUME" -lt 34 ]; then
      ICON="''${ICONS_VOLUME[1]}"
    elif [ "$VOLUME" -lt 67 ]; then
      ICON="''${ICONS_VOLUME[2]}"
    else
      ICON="''${ICONS_VOLUME[3]}"
    fi

    ${sketchybar} --set volume icon="$ICON" icon.color="$COLOR" label.color="$COLOR" label="$VOLUME%"
  '';

  home.file.".config/sketchybar/plugins/wifi.sh" = mkScript ''
    #!/usr/bin/env bash
    source "${pluginDir}/assets/colors.sh"
    source "${pluginDir}/assets/icons.sh"

    IFACE=en0
    STATE="/tmp/sketchybar_wifi_$IFACE.state"

    # macOS 26 hides the SSID ("<redacted>") from processes without Location
    # permission, so the label shows live throughput instead. An SSID line
    # (even redacted) means the interface is associated; none means Wi-Fi is off.
    SSID="$(/usr/sbin/ipconfig getsummary "$IFACE" 2>/dev/null | awk -F' : ' '/^  SSID +:/ { print $2 }')"

    if [ -z "$SSID" ]; then
      rm -f "$STATE"
      ${sketchybar} --set "$NAME" icon="$ICON_WIFI_OFF" icon.color=$COLOR_RED label.drawing=off
      exit 0
    fi

    # Cumulative bytes on the link-layer row of netstat
    read -r RX TX < <(/usr/sbin/netstat -ibn -I "$IFACE" | awk '/<Link#/ { print $7, $10; exit }')
    NOW=$(date +%s)

    RX_RATE=0; TX_RATE=0
    if [ -f "$STATE" ]; then
      read -r P_RX P_TX P_NOW < "$STATE"
      DT=$(( NOW - P_NOW ))
      if [ "$DT" -gt 0 ] && [ "$RX" -ge "$P_RX" ] && [ "$TX" -ge "$P_TX" ]; then
        RX_RATE=$(( (RX - P_RX) / DT ))
        TX_RATE=$(( (TX - P_TX) / DT ))
      fi
    fi
    echo "$RX $TX $NOW" > "$STATE"

    fmt() {
      # bytes/s -> compact human-readable, fixed width to avoid label jitter
      awk -v b="$1" 'BEGIN {
        if (b >= 1048576)   printf "%5.1fM", b / 1048576;
        else if (b >= 1024) printf "%5.0fK", b / 1024;
        else                printf "%5.0fB", b;
      }'
    }

    ${sketchybar} --set "$NAME" icon="$ICON_WIFI" icon.color=$COLOR_TEAL \
                                label.drawing=on \
                                label="↓$(fmt "$RX_RATE") ↑$(fmt "$TX_RATE")"
  '';

  home.file.".config/sketchybar/plugins/cpu.sh" = mkScript ''
    #!/usr/bin/env bash
    source "${pluginDir}/assets/colors.sh"

    CPU_LINE="$(/usr/bin/top -l 2 -n 0 | grep -E '^CPU' | tail -1)"
    USER="$(awk '{ print $3 }' <<< "$CPU_LINE" | tr -d '%')"
    SYS="$(awk '{ print $5 }' <<< "$CPU_LINE" | tr -d '%')"
    USAGE="$(awk -v u="''${USER:-0}" -v s="''${SYS:-0}" 'BEGIN { printf "%.0f", u + s }')"

    COLOR=$COLOR_GREEN
    if [ "$USAGE" -ge 80 ]; then
      COLOR=$COLOR_RED
    elif [ "$USAGE" -ge 50 ]; then
      COLOR=$COLOR_YELLOW
    fi

    ${sketchybar} --set "$NAME" icon.color="$COLOR" label="$USAGE%"
  '';

  home.file.".config/sketchybar/plugins/ram.sh" = mkScript ''
    #!/usr/bin/env bash
    source "${pluginDir}/assets/colors.sh"

    FREE="$(/usr/bin/memory_pressure 2>/dev/null | awk '/System-wide memory free percentage/ { print $5 }' | tr -d '%')"
    USED=$(( 100 - ''${FREE:-0} ))

    COLOR=$COLOR_GREEN
    if [ "$USED" -ge 80 ]; then
      COLOR=$COLOR_RED
    elif [ "$USED" -ge 50 ]; then
      COLOR=$COLOR_YELLOW
    fi

    ${sketchybar} --set "$NAME" icon.color="$COLOR" label="$USED%"
  '';

  # Now playing (Spotify first, then Apple Music). Polled: the native
  # media_change event is broken since macOS 15.4.
  home.file.".config/sketchybar/plugins/media.sh" = mkScript ''
    #!/usr/bin/env bash
    source "${pluginDir}/assets/colors.sh"
    source "${pluginDir}/assets/icons.sh"

    running() {
      /usr/bin/osascript -e "tell application \"System Events\" to (name of processes) contains \"$1\"" 2>/dev/null
    }

    PLAYER=""
    if [ "$(running Spotify)" = "true" ]; then
      PLAYER="Spotify"
    elif [ "$(running Music)" = "true" ]; then
      PLAYER="Music"
    fi

    if [ -z "$PLAYER" ]; then
      ${sketchybar} --set media drawing=off
      exit 0
    fi

    if [ "$1" = "toggle" ]; then
      /usr/bin/osascript -e "tell application \"$PLAYER\" to playpause" 2>/dev/null
      sleep 0.2
    fi

    STATE="$(/usr/bin/osascript -e "tell application \"$PLAYER\" to player state as string" 2>/dev/null)"

    case "$STATE" in
      playing|paused)
        TRACK="$(/usr/bin/osascript -e "tell application \"$PLAYER\" to name of current track" 2>/dev/null)"
        ARTIST="$(/usr/bin/osascript -e "tell application \"$PLAYER\" to artist of current track" 2>/dev/null)"
        LABEL="$TRACK"
        [ -n "$ARTIST" ] && LABEL="$TRACK – $ARTIST"
        if [ "$STATE" = "playing" ]; then
          ${sketchybar} --set media drawing=on icon="$ICON_MUSIC" icon.color=$COLOR_FLAMINGO label.color=$COLOR_TEXT label="$LABEL"
        else
          ${sketchybar} --set media drawing=on icon="$ICON_PAUSE" icon.color=$COLOR_SURFACE2 label.color=$COLOR_SURFACE2 label="$LABEL"
        fi
        ;;
      *)
        ${sketchybar} --set media drawing=off
        ;;
    esac
  '';
}
