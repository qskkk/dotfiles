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
  wallpaperSource = nixPath + secrets.wallpaperPath;

  nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };

  colorScheme = nix-colors.colorSchemes.${secrets.theme};
in
{
  imports = [
    ./hardware-configuration.nix
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
    os-prober  # detect Windows for GRUB dual-boot
    ntfs3g     # mount Windows NTFS partitions
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
        ./home-manager/home.nix
      ];

      home.sessionVariables.PATH = "$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH:";
    };

  # User configuration
  users.users."${username}" = {
    isNormalUser = true;
    home = homeDirectory;
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true;

  # Networking
  networking.hostName = secrets.nixosDesktopMachineName or "nixos-desktop";
  networking.networkmanager.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # compatibility for X11 games
  };

  # Login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Audio via PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # NVIDIA RTX 5080
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # RTX 5080 (Blackwell) requires open kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta; # 5080 needs latest drivers
  };

  # GPU & Gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit support for Steam/Proton
  };

  # AMD Ryzen — CPU governor & microcode
  hardware.cpu.amd.updateMicrocode = true;

  # Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  # Timezone and locale
  time.timeZone = "Europe/Paris";
  time.hardwareClockInLocalTime = true; # Windows dual-boot compat
  i18n.defaultLocale = "en_US.UTF-8";

  # Keyboard — Dvorak by default
  console.keyMap = "dvorak";            # TTY/console
  services.xserver.xkb.layout = "us";  # Xwayland
  services.xserver.xkb.variant = "dvorak";

  # System state version
  system.stateVersion = "24.05";
}
