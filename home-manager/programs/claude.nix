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
    text = builtins.toJSON {
      enabledPlugins = {};
      mcpServers = {
        linear = {
          type = "sse";
          url = "https://mcp.linear.app/mcp";
        };
      };
      alwaysThinkingEnabled = true;
    };
  };
}
