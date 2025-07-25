# Nix Darwin Dotfiles

A comprehensive dotfiles configuration for macOS using Nix Darwin, Home Manager, and Nix Flakes.

## 🌟 Features

- **Nix Flakes** - Reproducible and declarative system configuration
- **nix-darwin** - macOS system configuration management
- **Home Manager** - User environment and dotfiles management
- **nixvim** - Neovim configuration via Nix
- **nix-colors** - Consistent color theming across applications
- **Catppuccin Theme** - Beautiful, consistent theming throughout

## 🚀 Quick Start

### Prerequisites

1. **Install Nix** (if not already installed):

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Install nix-darwin**:
   ```bash
   nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
   ./result/bin/darwin-installer
   ```

### Setup

1. **Clone this repository**:

   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. **Configure secrets**:

   ```bash
   cp secrets.nix.example secrets.nix
   # Edit secrets.nix with your personal values
   ```

3. **Apply the configuration**:
   ```bash
   darwin-rebuild switch --flake .
   ```

## 🔒 Secrets Management

This configuration uses a `secrets.nix` file to store sensitive information that shouldn't be public.

### Setup your secrets:

1. Copy the example file:

   ```bash
   cp secrets.nix.example secrets.nix
   ```

2. Edit `secrets.nix` with your actual values:
   ```nix
   {
     username = "your-username";
     email = "your-email@example.com";
     goprivate = "github.com/your-company";
     workspaceUrl = "~/workspace/your-company/backend";
     githubOrg = "your-company";
   }
   ```

The `secrets.nix` file is gitignored and will never be committed to the repository.

## 📁 Structure

```
.
├── flake.nix                    # Main flake configuration
├── darwin-configuration.nix    # macOS system configuration
├── home-manager/
│   ├── home.nix                # Main home-manager configuration
│   ├── git.nix                 # Git configuration
│   ├── programs/               # Application configurations
│   │   ├── default.nix
│   │   ├── kitty.nix          # Terminal emulator
│   │   ├── neovim.nix         # Neovim configuration
│   │   └── vscode.nix         # VS Code configuration
│   └── shell/                  # Shell configuration
│       ├── default.nix
│       ├── zsh.nix            # Zsh configuration
│       ├── starship.nix       # Prompt configuration
│       └── aliases.nix        # Shell aliases
├── Makefile                    # Convenient commands
└── README.md                   # This file
```

## 🛠 Usage

### Daily Commands

```bash
# Build and switch to new configuration
make switch

# Update all inputs and rebuild
make upgrade

# Check configuration for errors
make check

# Clean old generations
make clean

# Rollback to previous generation
make rollback

# List all generations
make generations
```

### Development

```bash
# Format all Nix files
make format

# Test configuration
make test

# Enter development shell
make dev-shell
```

## 📦 What's Included

### System Applications (via Homebrew)

- **Browsers**: Arc, Firefox
- **Development**: VS Code, Docker, Postman
- **Productivity**: Raycast, Notion, Obsidian
- **Media**: Spotify, VLC
- **Utilities**: 1Password, CleanMyMac

### CLI Tools

- **Shell**: Zsh with Oh My Zsh, Starship prompt
- **Editor**: Neovim with comprehensive LSP setup
- **Terminal**: Kitty with Catppuccin theme
- **Git**: Enhanced with delta, aliases, and GitHub CLI
- **Search**: Ripgrep, fd, fzf
- **Navigation**: Zoxide, eza, tree
- **Development**: Node.js, Python, Go, Rust toolchains

### Development Features

- **Language Servers**: TypeScript, Go, Rust, Python, Nix
- **Formatters**: Prettier, Black, gofmt, rustfmt
- **Linters**: ESLint, Flake8, Clippy
- **Git Integration**: GitLens, Gitsigns
- **Fuzzy Finding**: Telescope, FZF integration

## 🎨 Theming

The configuration uses the **Catppuccin Mocha** theme consistently across:

- Terminal (Kitty)
- Editor (Neovim)
- VS Code
- Shell prompt (Starship)

Colors are managed centrally via nix-colors for consistency.

## ⚙️ Customization

### Adding New Applications

1. **System applications**: Add to `darwin-configuration.nix` in the `homebrew.casks` section
2. **CLI tools**: Add to `home-manager/home.nix` in the `home.packages` section
3. **Configurations**: Create new files in `home-manager/programs/`

### Modifying Existing Configurations

All application configurations are in separate Nix files for easy modification:

- Shell: `home-manager/shell/`
- Programs: `home-manager/programs/`
- Git: `home-manager/git.nix`

### Changing Themes

To change the color theme:

1. Browse available themes at [nix-colors](https://github.com/misterio77/nix-colors)
2. Update `colorScheme` in `home-manager/home.nix`
3. Rebuild with `make switch`

## 🚨 Troubleshooting

### Common Issues

1. **Permission errors**: Ensure you have admin privileges
2. **Build failures**: Run `make check` to validate configuration
3. **Outdated inputs**: Run `make update` to refresh dependencies
4. **Rollback needed**: Use `make rollback` to revert changes

### Getting Help

```bash
# Show available commands
make help

# Check system status
make show-config

# View build logs
darwin-rebuild switch --flake . --show-trace --verbose
```

## 🤝 Contributing

1. Fork the repository
2. Make your changes
3. Test with `make test`
4. Format code with `make format`
5. Submit a pull request

## 📄 License

This configuration is available under the MIT License. Feel free to use and modify as needed.

## 🙏 Acknowledgments

- Inspired by [blaadje's Mac-dotfiles](https://github.com/blaadje/Mac-dotfiles)
- Built with [nix-darwin](https://github.com/LnL7/nix-darwin)
- Uses [Home Manager](https://github.com/nix-community/home-manager)
- Themed with [Catppuccin](https://github.com/catppuccin/catppuccin)
- Colors via [nix-colors](https://github.com/misterio77/nix-colors)

---

**Happy coding! 🎉**
