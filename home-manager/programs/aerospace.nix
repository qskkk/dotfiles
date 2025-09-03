{
  config,
  pkgs,
  lib,
  ...
}:

let
  palette = config.colorScheme.palette;
in

{
  # AeroSpace configuration file
  home.file.".config/aerospace/aerospace.toml" = {
    text = ''
      # AeroSpace configuration based on your yabai/skhd setup

      # Global configuration options
      default-root-container-layout = 'tiles'
      default-root-container-orientation = 'auto'
      automatically-unhide-macos-hidden-apps = false

      # Enable accordion behavior for better grid-like arrangement
      accordion-padding = 30

      # Disable built-in Cmd+H and Cmd+M hiding/minimizing shortcuts
      enable-normalization-flatten-containers = true
      enable-normalization-opposite-orientation-for-nested-containers = true

      # Mouse follows focus when enabled, this setting is 'false' by default
      # on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

      # You can effectively turn off macOS "Hide application" (cmd-h) and "Minimize" (cmd-m) shortcuts
      # by assigning them to 'service-disable' binding
      # This way, you can use 'cmd-h' and 'cmd-m' in AeroSpace bindings without conflicts
      [mode.main.binding]

      # Window navigation (matching your alt-hjkl setup)
      alt-h = 'focus left'
      alt-j = 'focus down'
      alt-k = 'focus up'
      alt-l = 'focus right'

      # Window movement (matching your alt+shift-hjkl setup)
      alt-shift-h = 'move left'
      alt-shift-j = 'move down'
      alt-shift-k = 'move up'
      alt-shift-l = 'move right'

      # Toggle fullscreen (matching your alt+shift-0 setup)
      alt-shift-0 = 'fullscreen'
      ctrl-alt-cmd-shift-f = 'fullscreen'

      # Workspace navigation by numbers (matching your numbered spaces)
      alt-1 = 'workspace social'
      alt-2 = 'workspace spec'
      alt-3 = 'workspace obs'
      alt-4 = 'workspace code'
      alt-5 = 'workspace notes'
      alt-6 = 'workspace perso'
      alt-7 = 'workspace browser'
      alt-8 = 'workspace terminal'
      alt-9 = 'workspace db'

      # Workspace navigation by letters (matching your lettered spaces)
      alt-s = 'workspace social'
      alt-d = 'workspace code'
      alt-a = 'workspace browser'
      alt-w = 'workspace terminal'
      alt-b = 'workspace db'

      # Move window to workspace with numbers (standard move without grid trigger)
      alt-shift-1 = 'move-node-to-workspace social'
      alt-shift-2 = 'move-node-to-workspace spec'
      alt-shift-3 = 'move-node-to-workspace obs'
      alt-shift-4 = 'move-node-to-workspace code'
      alt-shift-5 = 'move-node-to-workspace notes'
      alt-shift-6 = 'move-node-to-workspace perso'
      alt-shift-7 = 'move-node-to-workspace browser'
      alt-shift-8 = 'move-node-to-workspace terminal'
      alt-shift-9 = 'move-node-to-workspace db'

      # Move window to workspace with letters (standard move without grid trigger)
      alt-shift-s = 'move-node-to-workspace social'
      alt-shift-d = 'move-node-to-workspace spec'
      alt-shift-a = 'move-node-to-workspace obs'
      alt-shift-w = 'move-node-to-workspace code'
      alt-shift-b = 'move-node-to-workspace notes'

      # Multi-monitor management (similar to your ctrl+alt+cmd shortcuts)
      ctrl-alt-cmd-left = 'move-node-to-monitor --wrap-around prev'
      ctrl-alt-cmd-right = 'move-node-to-monitor --wrap-around next'
      ctrl-alt-cmd-up = 'move-workspace-to-monitor --wrap-around next'
      ctrl-alt-cmd-down = 'move-workspace-to-monitor --wrap-around prev'

      # AeroSpace specific: switch between floating and tiling
      alt-shift-space = 'layout floating tiling'

      # AeroSpace specific: layout toggles
      alt-slash = 'layout tiles horizontal vertical'
      alt-comma = 'layout accordion horizontal vertical'

      # Resize to specific ratios for grid-like behavior
      alt-shift-equal = 'resize smart +50'  # Make current window larger
      alt-shift-minus = 'resize smart -50'  # Make current window smaller for grid

      # App assignment rules (based on your apps_to_spaces mapping)
      [[on-window-detected]]
      if.app-id = 'com.tinyspeck.slackmacgap'
      run = 'move-node-to-workspace social'

      [[on-window-detected]]
      if.app-id = 'com.apple.MobileSMS'
      run = 'move-node-to-workspace social'

      [[on-window-detected]]
      if.app-id = 'com.linear'
      run = 'move-node-to-workspace spec'

      [[on-window-detected]]
      if.app-id = 'com.apple.iCal'
      run = 'move-node-to-workspace social'

      [[on-window-detected]]
      if.app-id = 'com.apple.mail'
      run = 'move-node-to-workspace social'

      [[on-window-detected]]
      if.app-id = 'com.hnc.Discord'
      run = 'move-node-to-workspace social'

      [[on-window-detected]]
      if.app-id = 'com.apple.Safari'
      run = 'move-node-to-workspace browser'

      [[on-window-detected]]
      if.app-id = 'com.apple.Terminal'
      run = 'move-node-to-workspace terminal'

      [[on-window-detected]]
      if.app-id = 'com.github.wez.wezterm'
      run = 'move-node-to-workspace terminal'

      [[on-window-detected]]
      if.app-id = 'net.kovidgoyal.kitty'
      run = 'move-node-to-workspace terminal'

      [[on-window-detected]]
      if.app-id = 'com.jetbrains.WebStorm'
      run = 'move-node-to-workspace code'

      [[on-window-detected]]
      if.app-id = 'com.apple.dt.Xcode'
      run = 'move-node-to-workspace code'

      [[on-window-detected]]
      if.app-id = 'com.microsoft.VSCode'
      run = 'move-node-to-workspace code'

      [[on-window-detected]]
      if.app-id = 'com.jetbrains.goland'
      run = 'move-node-to-workspace code'

      [[on-window-detected]]
      if.app-id = 'notion.id'
      run = 'move-node-to-workspace notes'

      # Arc browser specific rules
      # Arc without title should be floating
      [[on-window-detected]]
      if.app-id = 'company.thebrowser.Browser'
      if.window-title-regex-substring = '^ *$'
      run = 'layout floating'

      # Arc browser general rule
      [[on-window-detected]]
      if.app-id = 'company.thebrowser.Browser'
      run = 'move-node-to-workspace browser'

      [[on-window-detected]]
      if.app-id = 'io.zen.Zen'
      run = 'move-node-to-workspace browser'

      [[on-window-detected]]
      if.app-id = 'com.google.Chrome'
      run = 'move-node-to-workspace browser'

      [[on-window-detected]]
      if.app-id = 'dev.warp.Warp-Stable'
      run = 'move-node-to-workspace terminal'

      [[on-window-detected]]
      if.app-id = 'org.jkiss.dbeaver.core.product'
      run = 'move-node-to-workspace db'

      [[on-window-detected]]
      if.app-id = 'com.postmanlabs.mac'
      run = 'move-node-to-workspace db'

      [[on-window-detected]]
      if.app-id = 'com.softfever3d.orca-slicer'
      run = 'move-node-to-workspace perso'

      [[on-window-detected]]
      if.app-id = 'com.autodesk.fusion360'
      run = 'move-node-to-workspace perso'

      [[on-window-detected]]
      if.app-id = 'company.thebrowser.Browser'
      if.window-title-regex-substring = '.*Developer Tools.*'
      run = 'layout tiling'

      [[on-window-detected]]
      if.app-id = 'com.google.Chrome'
      if.window-title-regex-substring = '.*Developer Tools.*'
      run = 'layout tiling'

      [[on-window-detected]]
      if.app-id = 'com.apple.Safari'
      if.window-title-regex-substring = '.*Web Inspector.*'
      run = 'layout tiling'

      # Default rule for any window - set to tiling layout
      [[on-window-detected]]
      run = 'layout tiling'

      # Gaps and padding (similar to your yabai config)
      [gaps]
      inner.horizontal = 15
      inner.vertical = 15
      outer.left = 20
      outer.bottom = 10
      outer.top = 40
      outer.right = 20

      # Workspace to monitor assignment (based on your display setup)
      [workspace-to-monitor-force-assignment]
      social = 'Built-in Retina Display'
      spec = 'Built-in Retina Display'
      obs = 'Built-in Retina Display'
      code = 'XG2730 SERIES'
      notes = 'XG2730 SERIES'
      perso = 'XG2730 SERIES'
      browser = 'BenQ GW2490E'
      terminal = 'BenQ GW2490E'
      db = 'BenQ GW2490E'
    '';
    executable = false;
  };

  # LaunchAgent for AeroSpace with our configuration
  launchd.agents.aerospace = {
    enable = true;
    config = {
      Label = "aerospace";
      ProgramArguments = [
        "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace"
        "--config-path"
        "${config.home.homeDirectory}/.config/aerospace/aerospace.toml"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardOutPath = "/tmp/aerospace.log";
      StandardErrorPath = "/tmp/aerospace.log";
    };
  };

  # LaunchAgent for JankyBorders
  launchd.agents.jankyborders = {
    enable = true;
    config = {
      Label = "jankyborders";
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "active_color=0xff${palette.base0D}"
        "inactive_color=0xff${palette.base04}"
        "width=10.0"
        "style=round"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardOutPath = "/tmp/jankyborders.log";
      StandardErrorPath = "/tmp/jankyborders.log";
    };
  };
}
