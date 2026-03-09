{
  config,
  pkgs,
  lib,
  colorScheme,
  username,
  nixPath,
  secrets,
  ...
}:

{
  # skhd configuration
  home.file.".claude/settings.json" = {
    text = ''
      {
        "enabledPlugins": {
          "gopls-lsp@claude-plugins-official": true,
          "typescript-lsp@claude-plugins-official": true,
          "stella@stella": true
        },
        "alwaysThinkingEnabled": true
      }
    '';
  };
}
