{ config, secrets, ... }:

let
  # Map nix-colors theme names to delta syntax themes
  deltaThemeMap = {
    "catppuccin-mocha" = "Catppuccin-mocha";
    "catppuccin-macchiato" = "Catppuccin-macchiato";
    "catppuccin-frappe" = "Catppuccin-frappe";
    "catppuccin-latte" = "Catppuccin-latte";
    "everforest" = "ansi";
    "rose-pine" = "ansi";
    "rose-pine-moon" = "ansi";
    "nord" = "Nord";
    "dracula" = "Dracula";
    "gruvbox-dark-hard" = "gruvbox-dark";
    "gruvbox-dark-medium" = "gruvbox-dark";
    "gruvbox-dark-soft" = "gruvbox-dark";
    "gruvbox-light-hard" = "gruvbox-light";
    "gruvbox-light-medium" = "gruvbox-light";
    "gruvbox-light-soft" = "gruvbox-light";
    "monokai" = "Monokai Extended";
    "solarized-dark" = "Solarized (dark)";
    "solarized-light" = "Solarized (light)";
    "tokyo-night-dark" = "TwoDark";
    "tokyo-night-light" = "GitHub";
    "onedark" = "OneHalfDark";
    "onelight" = "OneHalfLight";
  };

  # Get the delta theme based on the current nix-colors theme
  deltaTheme = deltaThemeMap.${secrets.theme} or "base16";
in
{
  programs.git = {
    enable = true;
    userName = secrets.username or "your-username";
    userEmail = secrets.email or "your-email@example.com";

    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      pull.rebase = true;
      push.default = "simple";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";

      # Better diff algorithm
      diff.algorithm = "patience";

      # Reuse recorded resolution
      rerere.enabled = true;

      # GPG signing (optional)
      # commit.gpgsign = true;
      # user.signingkey = "$GITHUB_TOKEN";
    };

    # Git aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      brc = "branch --show-current";
      ci = "commit";
      ca = "commit -a";
      cam = "commit -am";
      cl = "clone";
      cp = "cherry-pick";
      df = "diff";
      dc = "diff --cached";
      lg = "log --oneline --graph --decorate --all";
      lga = "log --graph --pretty=format:'%C(yellow)%h%Creset -%C(red)%d%Creset %s %C(green)(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      pushf = "push --force-with-lease";
      amend = "commit --amend --no-edit";
      fixup = "commit --fixup";
      squash = "rebase -i --autosquash";
    };

    # Delta for better diffs
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = deltaTheme;
      };
    };
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      editor = "nvim";
      git_protocol = "https";
      prompt = "enabled";
    };
  };
}
