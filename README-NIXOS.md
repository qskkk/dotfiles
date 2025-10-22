# NixOS Configuration Setup

This repository now supports both macOS (Darwin) and NixOS configurations using the same home-manager setup.

## Quick Start for NixOS

### 1. Initial Setup on NixOS Machine

First, install NixOS on your machine if you haven't already.

### 2. Generate Hardware Configuration

On your NixOS machine, generate the hardware configuration:

```bash
sudo nixos-generate-config --root /mnt
```

Copy the generated `hardware-configuration.nix` from `/mnt/etc/nixos/hardware-configuration.nix` and replace the template file in this repository.

### 3. Update secrets.nix

Add your NixOS machine name to `secrets.nix`:

```nix
{
  username = "your-username";
  machineName = "your-mac-name";      # Your Darwin machine
  nixosMachineName = "your-nixos-name";  # Your NixOS machine
  theme = "catppuccin-mocha";
  wallpaperPath = "assets/your-wallpaper.jpg";
}
```

### 4. Clone Repository on NixOS

```bash
mkdir -p ~/workspace/perso
cd ~/workspace/perso
git clone <your-repo-url> dotfiles
cd dotfiles
```

### 5. Build and Apply Configuration

```bash
# Build the configuration
sudo nixos-rebuild switch --flake .#your-nixos-machine-name

# Or use the machine name from secrets.nix
sudo nixos-rebuild switch --flake .
```

## Key Differences from Darwin Config

### Platform-Specific Packages

The configuration automatically detects the platform and installs appropriate packages:

- **macOS only**: aerospace, sketchybar, karabiner-elements
- **Linux only**: (you can add Linux-specific packages as needed)
- **Cross-platform**: All CLI tools work on both systems

### Platform-Specific Activation Scripts

- macOS-specific activation scripts (SketchyBar, Karabiner, Aerospace, Warp) only run on Darwin
- Linux activation scripts can be added in a similar manner

### Home Directory Paths

- macOS: `/Users/username`
- NixOS: `/home/username`

Both are handled automatically via `pkgs.stdenv.isDarwin` checks.

## File Structure

```
dotfiles/
├── flake.nix                    # Main flake with both Darwin and NixOS outputs
├── darwin-configuration.nix      # macOS system configuration
├── nixos-configuration.nix       # NixOS system configuration
├── hardware-configuration.nix    # NixOS hardware config (replace with yours)
├── home-manager/
│   ├── home.nix                 # Cross-platform home-manager config
│   ├── programs/                # Program configurations
│   └── shell/                   # Shell configurations
└── secrets.nix                  # Secrets and machine names
```

## Customizing for NixOS

### Desktop Environment

Add to `nixos-configuration.nix`:

```nix
# For GNOME
services.xserver.enable = true;
services.xserver.displayManager.gdm.enable = true;
services.xserver.desktopManager.gnome.enable = true;

# For KDE Plasma
services.xserver.enable = true;
services.xserver.displayManager.sddm.enable = true;
services.xserver.desktopManager.plasma5.enable = true;

# For i3/Sway
services.xserver.windowManager.i3.enable = true;
# or
programs.sway.enable = true;
```

### Additional System Packages

Edit `nixos-configuration.nix` and add packages to `environment.systemPackages`.

### Graphics Drivers

Add to `nixos-configuration.nix`:

```nix
# For NVIDIA
services.xserver.videoDrivers = [ "nvidia" ];

# For AMD
services.xserver.videoDrivers = [ "amdgpu" ];
```

## Updating the Configuration

```bash
# On NixOS
cd ~/workspace/perso/dotfiles
git pull
sudo nixos-rebuild switch --flake .

# On macOS (existing workflow)
cd ~/workspace/perso/dotfiles
git pull
darwin-rebuild switch --flake .
```

## Troubleshooting

### git-fleet package architecture

The configuration automatically uses the correct architecture:
- Darwin: `aarch64-darwin`
- NixOS: `x86_64-linux`

If you're using ARM Linux, update the architecture in `flake.nix`.

### Custom nixPath

If your dotfiles are in a different location on NixOS, update `nixPathLinux` in `flake.nix`:

```nix
nixPathLinux = "/your/custom/path/dotfiles";
```

## Migration Checklist

- [ ] Install NixOS
- [ ] Generate and replace `hardware-configuration.nix`
- [ ] Update `secrets.nix` with NixOS machine name
- [ ] Clone dotfiles to `~/workspace/perso/dotfiles` (or update nixPath)
- [ ] Run `sudo nixos-rebuild switch --flake .`
- [ ] Configure desktop environment (if needed)
- [ ] Add any Linux-specific packages to home.nix
