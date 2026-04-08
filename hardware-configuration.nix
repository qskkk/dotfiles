# Hardware configuration for NixOS
# This is a template - you should replace this with your actual hardware configuration
# Run `nixos-generate-config` on your NixOS machine to generate the proper hardware-configuration.nix

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # Boot loader — systemd-boot (EFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # File systems - REPLACE THIS with output from nixos-generate-config
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Swap devices - adjust as needed
  # swapDevices = [ ];

  # Enable networking
  networking.useDHCP = lib.mkDefault true;
}
