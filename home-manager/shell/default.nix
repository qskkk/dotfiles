{ config, pkgs, secrets, ... }:

{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./aliases.nix
  ];
}
