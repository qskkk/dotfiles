{
  description = "Nix Darwin System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    nixvim.url = "github:nix-community/nixvim";
    nix-colors.url = "github:misterio77/nix-colors";

    home-manager.url = "github:nix-community/home-manager";

    git-fleet.url = "github:qskkk/git-fleet";

    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      home-manager,
      nix-colors,
      nixvim,
      git-fleet,
      ...
    }:
    let
      system = "aarch64-darwin";

      nixPath = "/Users/qskkk/workspace/perso/dotfiles";

      secrets = import (nixPath + "/secrets.nix");

      username = secrets.username;

    in
    {
      # Use machine name from secrets
      darwinConfigurations."${secrets.machineName}" = darwin.lib.darwinSystem {
        inherit system;

        specialArgs = {
          inherit
            nix-colors
            nixvim
            username
            secrets
            nixPath
            git-fleet
            ;
        };

        modules = [
          (
            { pkgs, ... }:
            {
              environment.systemPackages = [
                git-fleet.packages.aarch64-darwin.default
              ];
            }
          )
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          nix-colors.homeManagerModule
        ];
      };
    };
}
