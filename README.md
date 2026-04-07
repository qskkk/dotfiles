# Dotfiles

macOS and NixOS dotfiles managed with Nix Darwin, Home Manager, and Nix Flakes.

## Features

- **nix-darwin** — macOS system configuration
- **NixOS** — Linux desktop configuration (Hyprland + NVIDIA)
- **Home Manager** — shared user environment and program configs
- **nix-colors** — consistent theming across apps

### macOS
- **AeroSpace** — tiling window manager
- **Sketchybar** — custom menu bar
- **Karabiner-Elements** — keyboard remapping

### NixOS
- **Hyprland** — tiling Wayland compositor
- **Waybar** — status bar
- **Wofi** — app launcher
- **Steam / Gamescope / Gamemode** — gaming support

## Prerequisites

1. **Install Nix** (Determinate installer recommended):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Enable flakes** — already enabled if you used the Determinate installer. Otherwise add to `/etc/nix/nix.conf`:

   ```
   experimental-features = nix-command flakes
   ```

## Setup

1. **Clone the repo** to the expected path:

   ```bash
   git clone <repo-url> ~/workspace/perso/dotfiles
   cd ~/workspace/perso/dotfiles
   ```

   > The flake uses this path. Cloning elsewhere requires updating `getNixPath` in `flake.nix`.

2. **Configure secrets**:

   ```bash
   cp secrets.nix.example secrets.nix
   ```

   Edit `secrets.nix` and fill in your values:

   ```nix
   {
     username = "your-username";
     email = "your@email.com";
     machineName = "Your-MacBook-Pro";            # macOS hostname
     nixosDesktopMachineName = "your-nixos-pc";   # NixOS desktop hostname
     nixosServerMachineName = "your-nixos-server"; # NixOS server hostname
     wallpaperPath = "assets/green.jpg";
     theme = "everforest";
     ...
   }
   ```

3. **Bootstrap** (first time only):

   **macOS:**
   ```bash
   nix run nix-darwin -- switch --flake ~/workspace/perso/dotfiles/. --impure
   ```

   **NixOS:**
   ```bash
   sudo nixos-rebuild switch --flake ~/workspace/perso/dotfiles/. --impure
   ```

4. **Apply the configuration**:

   ```bash
   make switch         # macOS (darwin-rebuild)
   make nixos-switch   # NixOS (nixos-rebuild)
   ```

## Daily Usage

```bash
make switch         # macOS — rebuild and switch
make nixos-switch   # NixOS — rebuild and switch
```

### Wallpaper / theme presets

```bash
make wall-pink   # Rose Pine Moon theme
make wall-blue   # Catppuccin Mocha theme
make wall-green  # Everforest theme
make wall-rand   # random wallpaper from assets/
```

### Updating inputs

```bash
nix flake update                          # update all inputs
nix flake update home-manager            # update a single input
make switch                               # apply updates
```

### Rollback

```bash
darwin-rebuild --rollback          # macOS
sudo nixos-rebuild switch --rollback  # NixOS
```

## Structure

```
.
├── flake.nix                     # inputs, outputs, system definitions
├── darwin-configuration.nix      # macOS system config (brew, defaults, etc.)
├── nixos-configuration.nix       # NixOS desktop config (Hyprland, NVIDIA, Steam)
├── hardware-configuration.nix    # NixOS hardware (replace with nixos-generate-config output)
├── server-nixos-configuration.nix # NixOS server config
├── home-manager/
│   ├── home.nix                  # main home-manager entrypoint (shared)
│   ├── git.nix                   # git config
│   ├── programs/
│   │   ├── default.nix           # imports all programs (conditional per OS)
│   │   ├── aerospace.nix         # tiling WM (macOS)
│   │   ├── hyprland.nix          # tiling compositor (NixOS) + Waybar + Wofi
│   │   ├── sketchybar.nix        # menu bar (macOS)
│   │   ├── karabiner.nix         # keyboard remapping (macOS)
│   │   ├── warp.nix              # Warp terminal (macOS)
│   │   ├── orbstack.nix          # containers (macOS)
│   │   ├── vscode.nix            # cross-platform
│   │   ├── zed.nix               # cross-platform
│   │   └── scripts.nix           # custom shell scripts
│   └── shell/
│       ├── zsh.nix
│       ├── starship.nix
│       └── aliases.nix
├── pkgs/                         # custom derivations
├── secrets.nix                   # gitignored — personal values
├── secrets.nix.example           # template for secrets.nix
├── Makefile
└── CLAUDE.md                     # guidelines for AI assistance
```

## Secrets

`secrets.nix` is gitignored. It holds personal values passed to modules via `specialArgs`.
Always use `secrets.nix.example` as the source of truth for required fields.

## NixOS Desktop Setup

### First install

1. Install NixOS with the minimal ISO
2. Clone this repo to `~/workspace/perso/dotfiles`
3. Generate your hardware config and replace the template:
   ```bash
   nixos-generate-config --show-hardware-config > ~/workspace/perso/dotfiles/hardware-configuration.nix
   ```
4. Configure `secrets.nix` (set `nixosDesktopMachineName` to your hostname)
5. Apply:
   ```bash
   make nixos-switch
   ```

### Hardware

The NixOS desktop config includes:
- **NVIDIA RTX 5080** — open kernel module + beta drivers (required for Blackwell)
- **AMD Ryzen** — microcode updates
- **Hyprland** — Wayland compositor with NVIDIA-specific env vars
- **Steam** — with Gamescope and Gamemode for gaming
- **PipeWire** — audio (ALSA + PulseAudio compat + 32-bit)
- **Bluetooth** and **Docker** enabled

### Hyprland keybindings

Same muscle memory as AeroSpace on macOS:

| Keybind | Action |
|---|---|
| `Alt + H/J/K/L` | Focus left/down/up/right |
| `Alt + Shift + H/J/K/L` | Move window |
| `Alt + 1-9` | Switch workspace |
| `Alt + Shift + 1-9` | Move window to workspace |
| `Alt + S/D/A/W/B` | Quick workspace (social/code/browser/terminal/db) |
| `Alt + Shift + Space` | Toggle floating |
| `Alt + Shift + 0` | Fullscreen |
| `Alt + Q` | Close window |
| `Alt + Return` | Open terminal (Kitty) |
| `Alt + Space` | App launcher (Wofi) |

### GPU-specific notes

If you have a different GPU, update `nixos-configuration.nix`:
- **AMD GPU**: remove the `hardware.nvidia` block, it works out of the box
- **Intel GPU**: remove the `hardware.nvidia` block, add `hardware.graphics.extraPackages = [ pkgs.intel-media-driver ]`
- **Other NVIDIA**: change `nvidiaPackages.beta` to `nvidiaPackages.stable` if your card is supported

## Troubleshooting

**Build fails with "attribute missing" or similar**
Check that all required fields in `secrets.nix` match `secrets.nix.example`.

**`machineName` mismatch**
The flake key must match your machine's hostname. Check with `scutil --get LocalHostName` (macOS) or `hostnamectl` (NixOS).

**`--impure` is required**
This config reads `secrets.nix` from the filesystem at eval time, so `--impure` is always needed.

**NVIDIA + Hyprland flickering**
Make sure `hardware.nvidia.modesetting.enable = true` and the env vars in `hyprland.nix` are set.

**Show full error trace**
```bash
sudo darwin-rebuild switch --flake ~/workspace/perso/dotfiles/. --impure --show-trace   # macOS
sudo nixos-rebuild switch --flake ~/workspace/perso/dotfiles/. --impure --show-trace    # NixOS
```

## Acknowledgments

- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)
- [nix-colors](https://github.com/misterio77/nix-colors)
- [nixvim](https://github.com/nix-community/nixvim)
