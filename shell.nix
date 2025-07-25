{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Nix tools
    nixpkgs-fmt
    statix
    nil
    
    # Development tools
    git
    gnumake
    
    # Documentation
    mdbook
    
    # Utilities
    tree
    bat
    fd
    ripgrep
  ];

  shellHook = ''
    echo "🎉 Welcome to the Nix Darwin Dotfiles development environment!"
    echo ""
    echo "Available commands:"
    echo "  make help     - Show all available commands"
    echo "  make check    - Check configuration for errors"
    echo "  make build    - Build the configuration"
    echo "  make switch   - Build and switch to new configuration"
    echo "  make format   - Format all Nix files"
    echo ""
    echo "Happy configuring! 🚀"
  '';
}
