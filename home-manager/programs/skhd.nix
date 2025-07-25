{
  config,
  pkgs,
  lib,
  colorScheme,
  username,
  nixPath,
  ...
}:

{
  # skhd configuration
  home.file.".skhdrc" = {
    text = ''
      # Window navigation
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      # Window movement
      alt + shift - h : yabai -m window --warp west
      alt + shift - j : yabai -m window --warp south
      alt + shift - k : yabai -m window --warp north
      alt + shift - l : yabai -m window --warp east

      # Window resizing (commented out in original)
      #ctrl + shift - minus : yabai -m window --resize left:-50:0 ; yabai -m window --resize right:-50:0
      #ctrl + shift - equal : yabai -m window --resize left:50:0 ; yabai -m window --resize right:50:0

      # Toggle fullscreen
      alt + shift - 0 : yabai -m window --toggle zoom-fullscreen

      # Space navigation (numbered)
      alt - 1 : yabai -m space --focus social
      alt - 2 : yabai -m space --focus spec
      alt - 3 : yabai -m space --focus obs
      alt - 4 : yabai -m space --focus code
      alt - 5 : yabai -m space --focus notes
      alt - 6 : yabai -m space --focus perso
      alt - 7 : yabai -m space --focus browser
      alt - 8 : yabai -m space --focus terminal
      alt - 9 : yabai -m space --focus db

      # Space navigation (lettered)
      alt - s : yabai -m space --focus social
      alt - d : yabai -m space --focus code
      alt - a : yabai -m space --focus browser
      alt - w : yabai -m space --focus terminal
      alt - b : yabai -m space --focus db

      # Move window to space (numbered)
      alt + shift - 1 : yabai -m window --space social; yabai -m space --focus social
      alt + shift - 2 : yabai -m window --space spec; yabai -m space --focus spec
      alt + shift - 3 : yabai -m window --space obs; yabai -m space --focus obs
      alt + shift - 4 : yabai -m window --space code; yabai -m space --focus code
      alt + shift - 5 : yabai -m window --space notes; yabai -m space --focus notes
      alt + shift - 6 : yabai -m window --space perso; yabai -m space --focus perso
      alt + shift - 7 : yabai -m window --space browser; yabai -m space --focus browser
      alt + shift - 8 : yabai -m window --space terminal; yabai -m space --focus terminal
      alt + shift - 9 : yabai -m window --space db; yabai -m space --focus db

      # Move window to space (lettered)
      alt + shift - s : yabai -m window --space social; yabai -m space --focus social
      alt + shift - d : yabai -m window --space spec; yabai -m space --focus spec
      alt + shift - a : yabai -m window --space obs; yabai -m space --focus obs
      alt + shift - w : yabai -m window --space code; yabai -m space --focus code
      alt + shift - b : yabai -m window --space notes; yabai -m space --focus notes

      # Multi-display management
      ctrl + alt + cmd - left : yabai -m window --display prev; yabai -m display --focus prev
      ctrl + alt + cmd - right : yabai -m window --display next; yabai -m display --focus next
      ctrl + alt + cmd - up : yabai -m space --display next; yabai -m display --focus next
      ctrl + alt + cmd - down : yabai -m space --display prev; yabai -m display --focus prev

      # Restart services
      ctrl + cmd + shift + alt - y : launchctl kickstart -k gui/$(id -u)/org.nixos.yabai; launchctl kickstart -k gui/$(id -u)/org.nixos.skhd
      ctrl + cmd + shift + alt - r : sudo darwin-rebuild switch --flake ${nixPath}/. --impure
    '';
  };
}
