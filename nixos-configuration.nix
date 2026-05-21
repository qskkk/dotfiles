{
  config,
  pkgs,
  lib,
  username,
  secrets,
  zen-browser,
  moza,
  ...
}:

{
  imports = [
    ./nixos-common.nix
    ./hardware-configuration.nix
  ];

  # Desktop-specific home-manager args
  home-manager.extraSpecialArgs.zen-browser = zen-browser;

  # Desktop-only user groups (merge with the base set in nixos-common.nix)
  users.users."${username}".extraGroups = [ "video" "audio" ];

  # Desktop-specific system packages
  environment.systemPackages = with pkgs; [
    os-prober  # detect Windows for GRUB dual-boot
    ntfs3g     # mount Windows NTFS partitions
    usbutils   # lsusb
    pciutils   # lspci
  ];

  # Hostname
  networking.hostName = secrets.nixosDesktopMachineName or "nixos-desktop";

  # Static IP — configure via NetworkManager (`nmtui` / `nmcli`) to avoid conflicts.

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

  # Noise cancellation for microphones (Yeti / Rode) — uses RNNoise
  programs.noisetorch.enable = true;

  # Bluetooth (MediaTek MT7925 on ASUS ProArt X870E)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  boot.kernelParams = [ "usb-storage.quirks=0e8d:7925:u" ];

  # Firmware (Bluetooth, WiFi, etc.)
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];

  # Docker
  virtualisation.docker.enable = true;

  # NVIDIA RTX 5080
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # RTX 5080 (Blackwell) requires open kernel module
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # GPU & Gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam/Proton 32-bit
  };

  # AMD Ryzen — CPU microcode
  hardware.cpu.amd.updateMicrocode = true;

  # Sunshine — game streaming server (Moonlight client on macOS)
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  # Firewall — extra ports for Moonlight/Sunshine streaming
  networking.firewall = {
    allowedTCPPorts = [ 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000; to = 8010; }
    ];
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

  # Windows dual-boot compat
  time.hardwareClockInLocalTime = true;

  # Keyboard — Dvorak by default
  console.keyMap = "dvorak";
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "dvorak";
  services.libinput.enable = true;

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

  # NixOS release version pinned for this host
  system.stateVersion = "24.05";
}
