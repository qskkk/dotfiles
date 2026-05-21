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
  colorScheme = nix-colors.colorSchemes.${secrets.theme};
in
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Shells
  programs.bash.enable = true;
  programs.zsh.enable = true;

  # Minimal common system packages (per-host packages live in their own files)
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];

  # Fonts (Nerd Fonts)
  fonts.packages =
    with pkgs;
    [ ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Sudo via wheel
  security.sudo.wheelNeedsPassword = true;

  # Networking — managed by NetworkManager, don't block boot waiting for it
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Locale / time
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  # Home Manager wiring (per-host args added in their own configs)
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
    # Default false; server-nixos-configuration.nix overrides to true
    isServer = lib.mkDefault false;
  };
  home-manager.users."${username}" = {
    fonts.fontconfig.enable = true;
    imports = [ ./home-manager/home.nix ];
    home.sessionVariables.PATH = "$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH:";
  };

  # Base user account (per-host extras like video/audio merge in via list-merge)
  users.users."${username}" = {
    isNormalUser = true;
    home = homeDirectory;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };
}
