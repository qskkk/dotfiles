{ pkgs }:

{
  go-1_25 = pkgs.callPackage ./go-1.25.nix {
    go_1_24 = pkgs.go_1_24;
  };
  tuios = pkgs.callPackage ./tuios.nix { };
}