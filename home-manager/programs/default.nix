{
  config,
  pkgs,
  secrets,
  ...
}:

{
  imports = [
    ./vscode.nix
    ./zed.nix
    ./scripts.nix
    ./aerospace.nix
    ./sketchybar.nix
    ./warp.nix
    ./karabiner.nix
    ./orbstack.nix
    ./hyprland.nix
  ];
}
