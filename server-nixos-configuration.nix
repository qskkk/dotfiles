{ ... }:

{
  imports = [
    ./nixos-common.nix
    ./server-config.nix
  ];

  # Tell home-manager this is a headless server (skips GUI/desktop bits in home.nix)
  home-manager.extraSpecialArgs.isServer = true;

  # NixOS release version pinned for this host
  system.stateVersion = "25.05";
}
