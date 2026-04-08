{
  config,
  pkgs,
  lib,
  nix-colors,
  nixvim,
  username,
  secrets,
  git-fleet,
  zen-browser,
  moza,
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
      zen-browser
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

  # Sunshine — game streaming server (Moonlight client on macOS)
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  # Moza sim racing — udev rules (universal-pidff driver is built into kernel 6.15+)
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", KERNEL=="ttyACM*", ATTRS{idVendor}=="346e", ACTION=="add", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="input", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
  '';

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
  services.libinput.enable = true;       # Mouse/touchpad/keyboard input

  # Caps Lock → Hyper (Ctrl+Alt+Shift+Super) like Karabiner on macOS
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "overload(hyper, esc)";  # Hold = Hyper, Tap = Escape
      };
      settings.hyper = {
        "u" = "C-A-S-M-u";
        "h" = "C-A-S-M-h";
        "j" = "C-A-S-M-j";
        "k" = "C-A-S-M-k";
        "l" = "C-A-S-M-l";
        "1" = "C-A-S-M-1";
        "2" = "C-A-S-M-2";
        "3" = "C-A-S-M-3";
        "4" = "C-A-S-M-4";
        "5" = "C-A-S-M-5";
        "6" = "C-A-S-M-6";
        "7" = "C-A-S-M-7";
        "8" = "C-A-S-M-8";
        "9" = "C-A-S-M-9";
        "0" = "C-A-S-M-0";
        "s" = "C-A-S-M-s";
        "d" = "C-A-S-M-d";
        "a" = "C-A-S-M-a";
        "w" = "C-A-S-M-w";
        "b" = "C-A-S-M-b";
        "q" = "C-A-S-M-q";
        "return" = "C-A-S-M-return";
        "space" = "C-A-S-M-space";
        "right" = "C-A-S-M-right";
        "left" = "C-A-S-M-left";
        "up" = "C-A-S-M-up";
        "down" = "C-A-S-M-down";
      };
    };
  };

  # System state version
  system.stateVersion = "24.05";
}
