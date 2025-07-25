{ config, ... }:

{
  # Configuration générale de Warp
  home.file.".warp/config.yaml".text = ''
    theme: custom-nix
  '';

  # Thème personnalisé Warp
  home.file.".warp/themes/custom-nix.yaml".text = ''
    name: Custom Nix Theme
    accent: "#${config.colorScheme.palette.base0D}"
    cursor: "#${config.colorScheme.palette.base05}"
    background: "#${config.colorScheme.palette.base00}"
    foreground: "#${config.colorScheme.palette.base05}"
    details: darker
    terminal_colors:
      normal:
        black: "#${config.colorScheme.palette.base00}"
        red: "#${config.colorScheme.palette.base08}"
        green: "#${config.colorScheme.palette.base0B}"
        yellow: "#${config.colorScheme.palette.base0A}"
        blue: "#${config.colorScheme.palette.base0D}"
        magenta: "#${config.colorScheme.palette.base0E}"
        cyan: "#${config.colorScheme.palette.base0C}"
        white: "#${config.colorScheme.palette.base05}"
      bright:
        black: "#${config.colorScheme.palette.base03}"
        red: "#${config.colorScheme.palette.base08}"
        green: "#${config.colorScheme.palette.base0B}"
        yellow: "#${config.colorScheme.palette.base0A}"
        blue: "#${config.colorScheme.palette.base0D}"
        magenta: "#${config.colorScheme.palette.base0E}"
        cyan: "#${config.colorScheme.palette.base0C}"
        white: "#${config.colorScheme.palette.base07}"
  '';
}
