{
  config,
  pkgs,
  lib,
  username,
  secrets,
  ...
}:

let
  homeDirectory = "/home/${username}";
  servicesDir = "${homeDirectory}/services";
in
{
  # Hardware config is generated per-machine by `nixos-generate-config` and
  # lives at /etc/nixos/hardware-configuration.nix. We import it via an
  # absolute path so the dotfiles repo stays portable across machines.
  # `--impure` is required (used by `make nixos-switch`).
  imports =
    if builtins.pathExists /etc/nixos/hardware-configuration.nix
    then [ /etc/nixos/hardware-configuration.nix ]
    else [ ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = secrets.nixosServerMachineName or "home-server";

  boot.kernel.sysctl = {
    # Disable IPv6
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;

    # TCP tuning
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";

    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_mtu_probing" = 1;
  };

  boot.kernelModules = [ "tcp_bbr" ];

  # Server: ignore lid switch, screen handled by lid-handler service below
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Custom lid handler: turn screen on/off via DPMS + brightness fallback
  systemd.services.lid-handler = {
    description = "Handle lid close/open: turn screen off/on";
    after = [ "acpid.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeShellScript "lid-handler" ''
        #!/bin/sh
        exec ${pkgs.acpid}/bin/acpi_listen | while read -r ev; do
          if echo "$ev" | grep -q "button/lid"; then
            state=$(awk '{print $2}' /proc/acpi/button/lid/LID*/state)
            if [ "$state" = "open" ]; then
              for f in /sys/class/backlight/*/bl_power; do
                [ -e "$f" ] && echo 0 > "$f" 2>/dev/null || true
              done
              for f in /sys/class/backlight/*/brightness; do
                [ -e "$f" ] && max=$(cat "$(dirname $f)/max_brightness") && echo $max > "$f" 2>/dev/null || true
              done
            else
              for f in /sys/class/backlight/*/bl_power; do
                [ -e "$f" ] && echo 4 > "$f" 2>/dev/null || true
              done
              for f in /sys/class/backlight/*/brightness; do
                [ -e "$f" ] && echo 0 > "$f" 2>/dev/null || true
              done
            fi
          fi
        done
      ''}";
    };
  };

  # FR locale subcategories on top of the en_US default set in server-nixos-configuration.nix
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22      # SSH
      80      # HTTP
      443     # HTTPS
      5353    # n8n
      32400   # Plex
      53      # Pi-hole DNS
      9987    # TeamSpeak voice
      10011   # TeamSpeak ServerQuery
      30033   # TeamSpeak file transfer
      28015   # Rust game (client)
      28016   # Rust game (RCON)
      8581    # Homebridge web interface
      51826   # Homebridge HomeKit
      51743   # Homebridge HomeKit
    ];
    allowedUDPPorts = [
      53      # Pi-hole DNS
      9987    # TeamSpeak voice
      28015   # Rust game (client)
      28082   # Rust game (query)
    ];
    allowPing = true;
    logRefusedConnections = true;
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = false;
  };

  # Auto-start docker-compose stacks
  systemd.services.docker-compose-foundry = {
    description = "Docker Compose Foundry VTT";
    after = [ "docker.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "${servicesDir}/foundry";
      ExecStart = "${pkgs.docker}/bin/docker compose up -d";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
      TimeoutStartSec = "5min";
    };
  };

  systemd.services.docker-compose-nginx = {
    description = "Docker Compose Nginx";
    after = [ "docker.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "${servicesDir}/nginx";
      ExecStart = "${pkgs.docker}/bin/docker compose up -d";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
      TimeoutStartSec = "5min";
    };
  };

  # Server-specific system packages
  environment.systemPackages = with pkgs; [
    docker
    ethtool
    claude-code
  ];
}
