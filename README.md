# Nix Darwin Dotfiles

macOS dotfiles managed with Nix Darwin, Home Manager, and Nix Flakes.

## Features

- **nix-darwin** — macOS system configuration
- **Home Manager** — user environment and program configs
- **nixvim** — Neovim configured via Nix
- **nix-colors** — consistent theming across apps
- **AeroSpace** — tiling window manager
- **Sketchybar** — custom menu bar

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

   Edit `secrets.nix` and fill in your values — at minimum `username` and `machineName`:

   ```nix
   {
     username = "your-username";
     email = "your@email.com";
     machineName = "Your-MacBook-Pro";  # must match your hostname
     ...
   }
   ```

3. **Bootstrap nix-darwin** (first time only):

   ```bash
   nix run nix-darwin -- switch --flake ~/workspace/perso/dotfiles/. --impure
   ```

4. **Apply the configuration**:

   ```bash
   make switch
   # equivalent to: sudo darwin-rebuild switch --flake ~/workspace/perso/dotfiles/. --impure
   ```

## Daily Usage

```bash
make switch      # rebuild and switch to the current configuration
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
darwin-rebuild --rollback
```

## Structure

```
.
├── flake.nix                     # inputs, outputs, system definitions
├── darwin-configuration.nix      # macOS system config (brew, defaults, etc.)
├── home-manager/
│   ├── home.nix                  # main home-manager entrypoint
│   ├── git.nix                   # git config
│   ├── programs/
│   │   ├── aerospace.nix         # tiling window manager
│   │   ├── sketchybar.nix        # menu bar
│   │   ├── vscode.nix
│   │   ├── warp.nix
│   │   ├── karabiner.nix
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

## Troubleshooting

**Build fails with "attribute missing" or similar**
Check that all required fields in `secrets.nix` match `secrets.nix.example`.

**`machineName` mismatch**
The flake key must match your machine's hostname. Check with `scutil --get LocalHostName`.

**`--impure` is required**
This config reads `secrets.nix` from the filesystem at eval time, so `--impure` is always needed.

**Show full error trace**
```bash
sudo darwin-rebuild switch --flake ~/workspace/perso/dotfiles/. --impure --show-trace
```

## Acknowledgments

- [nix-darwin](https://github.com/LnL7/nix-darwin)
- [Home Manager](https://github.com/nix-community/home-manager)
- [nix-colors](https://github.com/misterio77/nix-colors)
- [nixvim](https://github.com/nix-community/nixvim)
