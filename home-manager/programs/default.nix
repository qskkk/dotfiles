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
    # ./yabai.nix
    # ./skhd.nix
    # ./rift.nix
    ./aerospace.nix
    ./sketchybar.nix
    ./scripts.nix
    ./warp.nix
    ./karabiner.nix
    # ./nixvim.nix  # Removed - switching to Helix
    # ./claude.nix
    ./orbstack.nix
  ];
}
