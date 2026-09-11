{
  config,
  pkgs,
  lib,
  users,
  nix-colors,
  nixvim,
  username,
  secrets,
  git-fleet,
  ...
}:

let

  homeDirectory = "/Users/${username}";
  nixPath = homeDirectory + "/workspace/perso/dotfiles/";
  wallpaperSource = nixPath + secrets.wallpaperPath;

  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };

  colorScheme = nix-colors.colorSchemes.${secrets.theme};
in
{
  imports = [ nix-colors.homeManagerModule ];

  system.primaryUser = username;

  users.users."${username}".home = "/Users/${username}";

  ids.gids.nixbld = 350;
  ids.uids.nixbld = 350;

  nixpkgs.config.allowUnfree = true;

  nix = {
    # Optimisation continue : hardlink les fichiers identiques à chaque build
    optimise.automatic = true;

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      }; # dimanche 03:00
      options = "--delete-older-than 7d";
    };

    # Empêche l'accumulation infinie de générations à chaque rebuild
    settings = {
      auto-optimise-store = true;
      min-free = 5 * 1024 * 1024 * 1024; # 5 GB
      max-free = 20 * 1024 * 1024 * 1024; # 20 GB
    };
  };

  programs.fish.enable = true;
  programs.bash.enable = true;

  # services.yabai = {
  #   enable = true;
  #   enableScriptingAddition = true;
  # };

  # services.skhd = {
  #   enable = true;
  # };

  # services.aerospace = {
  #   enable = true;
  # };

  services.sketchybar = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    sketchybar
  ];

  homebrew = {
    enable = true;

    casks = [
      "obsidian"
      "orbstack"
      "warp"
      "zed"
      "zen"
    ];
  };

  fonts.packages =
    with pkgs;
    [ ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = {
    inherit
      nix-colors
      nixvim
      username
      colorScheme
      nixPath
      secrets
      git-fleet
      ;
  };
  home-manager.users."${username}" =
    { lib, ... }:
    {
      fonts = {
        fontconfig.enable = true;
      };

      imports = [
        ./home-manager/home.nix
      ];

      home.sessionVariables.PATH = "$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH:";
    };

  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
    dock = {
      autohide = true;
      static-only = true;
      orientation = "left";
    };
    NSGlobalDomain = {
      _HIHideMenuBar = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.swipescrolldirection" = true;
    };
  };

  system.stateVersion = 4;
}
