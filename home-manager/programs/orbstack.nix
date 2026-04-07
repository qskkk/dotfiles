{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf pkgs.stdenv.isDarwin (let
  # M3 Pro 36GB — reserve ~12GB for macOS, give OrbStack generous resources
  cpuLimit = 10; # M3 Pro has 11-12 cores
  memoryLimitMB = 24576; # 24GB for containers/VMs
in
{
  # Docker CLI config — use OrbStack as the Docker context
  home.file.".docker/config.json" = {
    text = builtins.toJSON {
      currentContext = "orbstack";
      plugins = { };
    };
  };

  # OrbStack settings optimized for M3 Pro 36GB
  home.file.".orbstack/config/config.json" = {
    text = builtins.toJSON {
      # Resource limits
      cpu = cpuLimit;
      memoryMiB = memoryLimitMB;
      diskSizeGiB = 256;

      # Performance — Apple Virtualization.framework is best on Apple Silicon
      useAppleVirtualization = true;
      useRosetta = true; # x86 emulation via Rosetta for amd64 images

      # Networking
      useDNSForwarder = true;
      useHostNetworking = false;

      # Docker-specific
      docker = {
        # BuildKit is faster and more cache-efficient
        features.buildkit = true;
        builder = "orbstack";
      };

      # Auto-updates
      autoUpdate = true;

      # Start on login for always-ready containers
      startAtLogin = true;
    };
  };

  # Docker buildx config — use OrbStack builder with multi-platform support
  home.file.".docker/buildx/instances/orbstack" = {
    text = builtins.toJSON {
      Name = "orbstack";
      Driver = "docker-container";
      Platforms = [
        "linux/arm64"
        "linux/amd64"
      ];
    };
  };
})
