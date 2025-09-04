{
  config,
  pkgs,
  lib,
  nix-colors,
  nixvim,
  username,
  colorScheme,
  nixPath,
  secrets,
  git-fleet,
  ...
}:

{
  # Import modules
  imports = [
    ./programs
    ./shell
    ./git.nix
    nix-colors.homeManagerModules.default
    nixvim.homeManagerModules.nixvim
  ];

  # Configure color scheme
  colorScheme = colorScheme;

  # Home Manager configuration
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "23.11";

    # Create npm global directory structure
    file.".npm-global/.keep".text = "";
    file.".npm-global/bin/.keep".text = "";
    file.".npm-global/lib/.keep".text = "";
    file.".npm-global/node_modules/.keep".text = "";

    # User packages
    packages = with pkgs; [
      # Terminal enhancements
      starship
      zoxide
      direnv # File management
      ranger
      nnn
      fzf
      fd
      ripgrep

      # ui tools
      # skhd
      # yabai
      aerospace
      sketchybar
      karabiner-elements

      # Text editors
      neovim

      # Networking
      openssh

      # Archive tools
      unzip
      p7zip

      # System monitoring
      btop

      # Other CLI tools
      ncdu
      tokei
      hyperfine # Window management dependencies
      jq
      jankyborders

      # CLI tools for scripts
      gum
      awscli2
      git-fleet.packages.aarch64-darwin.default
      newman

      # GO tools
      golangci-lint
      gopls
      go
      graphviz
      gopls

      #softs
      # orca-slicer
      # fusion360

      # Language servers for development
      nil # Nix LSP
      nixfmt-rfc-style # Nix formatter
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      rust-analyzer
      python3Packages.python-lsp-server

      # others
      # n
      nodejs
      yarn

      # node pagkages
      nodePackages.npm

      (writeShellScriptBin "install-ruben" ''
        export GOPATH="$HOME/go"
        export GOBIN="$HOME/go/bin"
        mkdir -p "$GOPATH/bin"
        go install github.com/japhy-team/ruben@main
      '')
    ];

    sessionPath = [
      "$HOME/go/bin"
      "/usr/local/bin"
      "$HOME/.npm-global/bin"
      "$HOME/.yarn/bin"
      "$HOME/.config/yarn/global/node_modules/.bin"
      "$HOME/dev/flutter/bin"
      "$HOME/.pub-cache/bin"
      "/opt/homebrew/bin"
      "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
      "/Applications/GoLand.app/Contents/MacOS"
    ];

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "arc";
      TERMINAL = "kitty";
      GOPATH = "$HOME/go";
      GOBIN = "$HOME/go/bin";
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # XDG directories
  xdg = {
    enable = true;
    configHome = "/Users/${username}/.config";
    dataHome = "/Users/${username}/.local/share";
    cacheHome = "/Users/${username}/.cache";
  };

  # Direnv integration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Activation script to restart SketchyBar after rebuild
  home.activation.restartSketchyBar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Restarting SketchyBar..."

    # Use the full path to sketchybar from nixpkgs
    if [ -x "${pkgs.sketchybar}/bin/sketchybar" ]; then
      $DRY_RUN_CMD ${pkgs.sketchybar}/bin/sketchybar --reload &
      echo "SketchyBar reload command sent"
    else
      echo "SketchyBar not found at ${pkgs.sketchybar}/bin/sketchybar"
    fi
  '';

  # Activation script to reload Karabiner-Elements configuration
  home.activation.reloadKarabiner = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Reloading Karabiner-Elements configuration..."

    # Check if Karabiner-Elements is installed
    if [ -d "/Applications/Karabiner-Elements.app" ]; then
      # Launch Karabiner-Elements if not running
      if ! pgrep -f "Karabiner-Elements" >/dev/null 2>&1; then
        echo "Starting Karabiner-Elements..."
        $DRY_RUN_CMD open -a "Karabiner-Elements" 2>/dev/null || true
        sleep 2
      fi
      
      # Use the correct CLI path
      if [ -x "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" ]; then
        echo "Selecting Default profile to reload configuration..."
        $DRY_RUN_CMD "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" --select-profile "Default profile" 2>/dev/null || true
      fi
      
      # Show notification about permissions if needed
      $DRY_RUN_CMD osascript -e 'display notification "Karabiner-Elements may need Accessibility permissions. Check System Settings > Privacy & Security > Accessibility" with title "Karabiner Configuration"' 2>/dev/null || true
      
      echo "Karabiner-Elements configuration reloaded"
    else
      echo "Karabiner-Elements not found in /Applications/"
      echo "Please install Karabiner-Elements manually or via Homebrew: brew install --cask karabiner-elements"
    fi
  '';

  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
    WALLPAPER_PATH="${nixPath}/${secrets.wallpaperPath}"

    if [ -f "$WALLPAPER_PATH" ]; then
      echo "Setting wallpaper to: $WALLPAPER_PATH"

      # Use osascript to set the wallpaper for all desktops
      /usr/bin/osascript -e "
        tell application \"System Events\"
          tell every desktop
            set picture to POSIX file \"$WALLPAPER_PATH\"
          end tell
        end tell
      " 2>/dev/null || true

      echo "Wallpaper set successfully"
    else
      echo "Warning: Wallpaper file not found at $WALLPAPER_PATH"
    fi
  '';

  # Activation script to refresh Warp theme after rebuild
  home.activation.refreshWarpTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Refreshing Warp theme..."

    if [ -x "$HOME/.scripts/refresh-warp-theme.sh" ]; then
      $DRY_RUN_CMD "$HOME/.scripts/refresh-warp-theme.sh" &
      echo "Warp theme refresh script executed"
    else
      echo "Warp theme refresh script not found"
    fi
  '';

  home.activation.reloadAerospace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Reloading Aerospace configuration..."

    if [ -x "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace" ]; then
      $DRY_RUN_CMD "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace" --reload &
      echo "Aerospace reload command sent"
    else
      echo "Aerospace not found at ${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace"
    fi
  '';

  # Activation script to install npm packages automatically
  home.activation.installNpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Installing npm packages..."

    export NPM_CONFIG_PREFIX="$HOME/.npm-global"

    # Ajouter d'autres packages npm ici
    NPM_PACKAGES=(
      "@anthropic-ai/claude-code"
      "typescript"
      "prettier"
      "eslint"
      "n"
    )

    for package in "''${NPM_PACKAGES[@]}"; do
      if [ ! -d "$NPM_CONFIG_PREFIX/lib/node_modules/$package" ]; then
        echo "Installing $package..."
        $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install -g "$package" 2>/dev/null || true
      else
        echo "$package already installed"
      fi
    done
  '';

  # Activation script to change wallpaper on all desktops/workspaces
  # home.activation.setWallpaper = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
  #   echo "Setting wallpaper for all workspaces..."

  #   WALLPAPER_PATH="${nixPath}/${secrets.wallpaperPath}"

  #   if [ -f "$WALLPAPER_PATH" ]; then
  #     echo "Setting wallpaper to: $WALLPAPER_PATH"

  #     # Use yabai to iterate through all spaces and set wallpaper
  #     if [ -x "${pkgs.yabai}/bin/yabai" ]; then
  #       # Get all currently visible spaces (one per display)
  #       VISIBLE_SPACES=$(${pkgs.yabai}/bin/yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[] | select(.["is-visible"] == true) | .index' 2>/dev/null || echo "")

  #       # Get all space IDs
  #       SPACES=$(${pkgs.yabai}/bin/yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[].index' 2>/dev/null || echo "")

  #       if [ -n "$SPACES" ]; then

  #         # For each space, focus it and set wallpaper
  #         for space_id in $SPACES; do

  #           # Focus the space
  #           $DRY_RUN_CMD ${pkgs.yabai}/bin/yabai -m space --focus "$space_id" 2>/dev/null || true
  #           sleep 0.3

  #           # Set wallpaper for current space
  #           $DRY_RUN_CMD /usr/bin/osascript -e "
  #             tell application \"System Events\"
  #               tell every desktop
  #                 set picture to \"$WALLPAPER_PATH\"
  #               end tell
  #             end tell
  #           " 2>/dev/null || true

  #         done

  #         # Return to all previously visible spaces (restore each display)
  #         if [ -n "$VISIBLE_SPACES" ]; then
  #           echo "Restoring all visible spaces: $VISIBLE_SPACES"
  #           for visible_space in $VISIBLE_SPACES; do
  #             echo "Restoring visible space $visible_space"
  #             $DRY_RUN_CMD ${pkgs.yabai}/bin/yabai -m space --focus "$visible_space" 2>/dev/null || true
  #             sleep 0.1
  #           done
  #           echo "All displays restored to their original state"
  #         fi
  #       else
  #         echo "No spaces found or yabai query failed, using simple method"
  #         $DRY_RUN_CMD /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER_PATH\"" 2>/dev/null || true
  #       fi
  #     else
  #       echo "yabai not found, using simple method"
  #       $DRY_RUN_CMD /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER_PATH\"" 2>/dev/null || true
  #     fi

  #     echo "Wallpaper setting completed"
  #   else
  #     echo "Warning: Wallpaper file not found at $WALLPAPER_PATH"
  #     echo "Available wallpapers in ${nixPath}/assets/:"
  #     ls -la "${nixPath}/assets/" 2>/dev/null || echo "Assets directory not found"
  #   fi
  # '';
}
