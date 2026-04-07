{
  config,
  pkgs,
  lib,
  nix-colors,
  nixvim,
  username,
  secrets,
  git-fleet,
  ...
}:

let
  homeDirectory = "/home/${username}";
  nixPath = secrets.nixosDotfilesPath or (homeDirectory + "/dotfiles/");
  
  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
  colorScheme = nix-colors.colorSchemes.${secrets.theme};
in
{
  imports = [
    ./server-config.nix  # Import server-specific configuration
    nix-colors.homeManagerModule
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable shells
  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    docker
  ];

  # Fonts
  fonts.packages =
    with pkgs;
    [ ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Home Manager configuration
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
        ./home-manager/server-home.nix  # Use server-specific home config
      ];

      home.sessionVariables.PATH = "$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH:";
    };

  # User configuration
  users.users."${username}" = {
    isNormalUser = true;
    home = homeDirectory;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true;

  # Networking
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  # System state version
  system.stateVersion = "25.05";
}
