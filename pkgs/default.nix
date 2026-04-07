{ pkgs }:

{
  go-1_26 = pkgs.callPackage ./go-1.26.nix {
    go_1_24 = pkgs.go_1_24;
  };
  tuios = pkgs.callPackage ./tuios.nix { };
}