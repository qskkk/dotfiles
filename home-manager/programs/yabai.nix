{
  config,
  pkgs,
  lib,
  ...
}:

let
  palette = config.colorScheme.palette;
  activeColor = "0xff${palette.base0D}";
  inactiveColor = "0xff${palette.base05}";
in

{
  # Yabai configuration
  home.file.".yabairc" = {
    text = ''
      #!/usr/bin/env bash
      #
      # for this to work you must configure sudo such that
      # it will be able to run the command without password
      #
      # see this wiki page for information:
      #  - https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition
      #
      sudo yabai --load-sa

      source ~/.scripts/yabai/common_func.sh
      source ~/.scripts/yabai/app_to_space.sh

      app_to_space

      # global settings
      yabai -m config                                 \
          mouse_follows_focus          on             \
          focus_follows_mouse          off            \
          window_origin_display        default        \
          window_placement             second_child   \
          window_zoom_persist          on             \
          window_shadow                on             \
          window_animation_duration    0.0            \
          window_opacity_duration      0.0            \
          active_window_opacity        1.0            \
          normal_window_opacity        1.0            \
          window_opacity               on             \
          insert_feedback_color        0xffd75f5f     \
          split_ratio                  0.50           \
          split_type                   auto           \
          auto_balance                 off            \
          top_padding                  40             \
          bottom_padding               10             \
          left_padding                 10             \
          right_padding                10             \
          window_gap                   15             \
          layout                       bsp            \
          mouse_modifier               fn             \
          mouse_action1                move           \
          mouse_action2                resize         \
          mouse_drop_action            swap

      yabai -m config window_placement second_child
      yabai -m config auto_balance off
      yabai -m config split_ratio 0.5

      yabai -m config mouse_follows_focus on
      #yabai -m config focus_follows_mouse autofocus

      yabai -m display 1 --label built-in
      yabai -m display 2 --label benq-right
      yabai -m display 3 --label AOC

      # Signals
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

      yabai -m signal --add event=display_added action="~/.scripts/yabai/display_management.sh"
      yabai -m signal --add event=display_removed action="~/.scripts/yabai/display_management.sh"
      yabai -m signal --add event=application_launched action="~/.scripts/yabai/app_to_space.sh"
      yabai -m signal --add event=window_created action="bash ~/.scripts/yabai/window_to_space.sh \$YABAI_WINDOW_ID $apps_to_spaces"

      bash ~/.scripts/yabai/display_management.sh
      borders active_color=${activeColor} inactive_color=${inactiveColor} width=10.0 &

      yabai -m signal --add event=window_created action="sketchybar -m --trigger window_change &> /dev/null"
      yabai -m signal --add event=window_destroyed action="sketchybar -m --trigger window_change &> /dev/null"

      echo "yabai configuration loaded.."
    '';
    executable = true;
  };

  # Yabai scripts directory
  home.file.".scripts/yabai/common_func.sh" = {
    text = ''
      #!/usr/bin/env bash

      move_app_to_space() {
          local app_name=$1
          local space_label=$2

          app_windows=$(yabai -m query --windows | jq -r --arg app_name "$app_name" '.[] | select(.app==$app_name) | .id')
          space_id=$(yabai -m query --spaces | jq -r --arg space_label "$space_label" '.[] | select(.label==$space_label) | .index')

          # Loop through each window ID and move it to the specified space
          for window_id in $app_windows; do
              yabai -m rule --add app="$app_name" space="^$space_id"
              yabai -m window $window_id --space $space_id
          done
      }

      move_window_to_space() {
          local window_id=$1
          local app_name=$2
          local space_label=$3

          space_id=$(yabai -m query --spaces | jq -r --arg space_label "$space_label" '.[] | select(.label==$space_label) | .index')

          echo "Moving window $window_id of app $app_name to space $space_label"

          yabai -m window $window_id --space $space_id
      }

      display_exists() {
          local display_id=$1
          if yabai -m query --displays | jq -r '.[].id' | grep -q "^$display_id$"; then
              return 0
          else
              return 1
          fi
      }

      move_space_if_needed() {
          local space_label=$1
          local target_display_id=$2

              if display_exists "$target_display_id"; then
                  current_display=$(yabai -m query --spaces --space $space_label | jq -r '.display')
                  SPACE_DISPLAY=$(yabai -m query  --displays | jq ".[] | select(.id == $target_display_id)")

                  if [ "$current_display" != "$target_display_id" ]; then
                    printf "Moving space %s to display %s\n" "$space_label" "$target_display_id"
                      yabai -m space $space_label --display $target_display_id
                  fi
              else
                SPACE_DISPLAY=$(yabai -m query  --displays | jq ".[] | select(.id == $current_display)")
              fi

          SPACE_DISPLAY_LABEL=$(echo "$SPACE_DISPLAY" | jq ".label" | tr -d '[:space:]')
          SPACE_DISPLAY_LABEL="''${SPACE_DISPLAY_LABEL//\"/}"

          SCREEN_HEIGHT=$(echo "$SPACE_DISPLAY" | jq ".frame.h")
          printf  "Space %s is on display %s\n" "$space_label" "$SPACE_DISPLAY_LABEL"
          if [ "$SPACE_DISPLAY_LABEL" == "built-in" ]; then
              PADDING=20
          else
              PADDING=$(echo "$SCREEN_HEIGHT" | awk '{print int(($1 / 25) / 10) * 10}')
          fi
          printf "Setting padding for space %s\n" "$space_label" "$PADDING"
          yabai -m space $space_label --padding abs:$PADDING:10:20:20
      }

      declare -gA apps_to_spaces=(
          ["Slack"]="social"
          ["Messages"]="social"
          ["Linear"]="spec"
          ["Calendar"]="social"
          ["Mail"]="social"
          ["Discord"]="social"
          ["Safari"]="browser"
          ["Terminal"]="terminal"
          ["Kitty"]="terminal"
          ["WebStorm"]="code"
          ["Xcode"]="code"
          ["VSCode"]="code"
          ["Code"]="code"
          ["GoLand"]="code"
          ["Notion"]="notes"
          ["Arc"]="browser"
          ["Zen"]="browser"
          ["Chrome"]="browser"
          ["Warp"]="terminal"
          ["DBeaver Community"]="db"
          ["DBeaver"]="db"
          ["Postman"]="db"
          ["OrcaSlicer"]="perso"
          ["System Settings"]="social"
      )
      declare -gA unmanaged_app_title=(
        ["Arc"]=""
      #    ["Slack"]="^Huddle"
      )
    '';
    executable = true;
  };

  home.file.".scripts/yabai/app_to_space.sh" = {
    text = ''
      #!/usr/bin/env bash

      source ~/.scripts/yabai/common_func.sh

      app_to_space() {
        app=$(yabai -m query --windows --window | jq -r '.app')
        title=$(yabai -m query --windows --window | jq -r '.title')

        if [[ -v unmanaged_app_title[$app] ]]; then
          ignore_pattern="''${unmanaged_app_title[$app]}"

          if [[ (-z "$ignore_pattern" && -z "$title") || (-n "$ignore_pattern" && "$title" =~ $ignore_pattern) ]]; then
            return 0
          fi
        fi

        targetSpace=''${apps_to_spaces[$app]}

        move_app_to_space $app $targetSpace

        yabai -m space --focus $targetSpace
      }

      app_to_space
    '';
    executable = true;
  };

  home.file.".scripts/yabai/display_management.sh" = {
    text = ''
      #!/usr/bin/env bash

      source ~/.scripts/yabai/common_func.sh

      BuiltInDisplayID=1
      AOCDisplayID=3
      BenqRightDisplayID=2

      yabai -m space 1 --label social
      yabai -m space 2 --label spec
      yabai -m space 3 --label obs

      yabai -m space 7 --label code
      yabai -m space 8 --label notes
      yabai -m space 9 --label perso

      yabai -m space 4 --label browser
      yabai -m space 5 --label terminal
      yabai -m space 6 --label db

      move_space_if_needed social $BuiltInDisplayID
      move_space_if_needed code $AOCDisplayID
      move_space_if_needed browser $BenqRightDisplayID
      move_space_if_needed spec $BuiltInDisplayID
      move_space_if_needed notes $AOCDisplayID
      move_space_if_needed terminal $BenqRightDisplayID
      move_space_if_needed obs $BuiltInDisplayID
      move_space_if_needed perso $AOCDisplayID
      move_space_if_needed db $BenqRightDisplayID

      # unmanaged apps
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off

      # Loop through the apps_to_spaces array and move apps accordingly
      for app in "''${!apps_to_spaces[@]}"; do
          move_app_to_space "$app" "''${apps_to_spaces[$app]}"
      done

      echo "Displays and applications have been reconfigured."
    '';
    executable = true;
  };

  home.file.".scripts/yabai/window_to_space.sh" = {
    text = ''
      #!/usr/bin/env bash

      source ~/.scripts/yabai/common_func.sh

      window_to_space() {
        apps_to_spaces=$2
        window_id="$1"

        app=$(yabai -m query --windows | jq --arg window_id "$window_id" -r '.[] | select(.id == ($window_id | tonumber)) | .app')

        if [[ -v unmanaged_app_title[$app] ]]; then
          ignore_pattern="''${unmanaged_app_title[$app]}"

          if [[ (-z "$ignore_pattern" && -z "$title") || (-n "$ignore_pattern" && "$title" =~ $ignore_pattern) ]]; then
            return 0
          fi
        fi

        targetSpace=''${apps_to_spaces[$app]}

        echo "Moving window $window_id of app $app to space $targetSpace"

        move_window_to_space "$window_id" "$app" "$targetSpace"

        yabai -m space --focus $targetSpace
      }

      window_to_space "$@"
    '';
    executable = true;
  };
}
