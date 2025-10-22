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
      darwinSystem = "aarch64-darwin";
      linuxSystem = "x86_64-linux";

      nixPathDarwin = "/Users/qskkk/workspace/perso/dotfiles";
      nixPathLinux = "/home/qskkk/workspace/perso/dotfiles";

      secrets = import (nixPathDarwin + "/secrets.nix");

      username = secrets.username;

    in
    {
      # Darwin configuration
      darwinConfigurations."${secrets.machineName}" = darwin.lib.darwinSystem {
        system = darwinSystem;

        specialArgs = {
          inherit
            nix-colors
            nixvim
            username
            secrets
            git-fleet
            ;
          nixPath = nixPathDarwin;
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

      # NixOS configuration
      nixosConfigurations."${secrets.nixosMachineName or "nixos"}" = nixpkgs.lib.nixosSystem {
        system = linuxSystem;

        specialArgs = {
          inherit
            nix-colors
            nixvim
            username
            secrets
            git-fleet
            ;
          nixPath = nixPathLinux;
        };

        modules = [
          (
            { pkgs, ... }:
            {
              environment.systemPackages = [
                git-fleet.packages.x86_64-linux.default
              ];
            }
          )
          ./nixos-configuration.nix
          home-manager.nixosModules.home-manager
          nix-colors.homeManagerModule
        ];
      };
    };
}
