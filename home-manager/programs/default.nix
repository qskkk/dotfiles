{
  config,
  pkgs,
  secrets,
  ...
}:

{
  imports = [
    ./vscode.nix
    # ./yabai.nix
    # ./skhd.nix
    ./aerospace.nix
    ./sketchybar.nix
    ./scripts.nix
    ./warp.nix
    ./karabiner.nix
  ];
}
