# Utilisation de la palette Nix-colors (base16, direct)
{
  config,
  lib,
  pkgs,
  ...
}:

let
  palette = config.colorScheme.palette;
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # General configuration
      add_newline = true;
      command_timeout = 1000;

      # Format
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$git_metrics"
        "$fill"
        "$nodejs"
        "$python"
        "$golang"
        "$rust"
        "$docker_context"
        "$time"
        "$line_break"
        "$character"
      ];

      # Modules configuration
      username = {
        style_user = "#${palette.base0D} bold";
        style_root = "#${palette.base08} bold";
        format = "[$user]($style) ";
        disabled = false;
        show_always = true;
      };

      hostname = {
        ssh_only = false;
        format = "on [$hostname](#${palette.base0E} bold) ";
        trim_at = ".companyname.com";
        disabled = false;
      };

      directory = {
        style = "#${palette.base0C}";
        truncation_length = 4;
        truncation_symbol = "…/";
        home_symbol = "~";
        read_only_style = "#${palette.base08}";
        read_only = "🔒";
        format = "at [$path]($style)[$read_only]($read_only_style) ";
      };

      character = {
        success_symbol = "[❯](#${palette.base0D})";
        error_symbol = "[❯](#${palette.base08})";
        vicmd_symbol = "[❮](#${palette.base0B})";
      };

      git_branch = {
        format = "on [$symbol$branch]($style) ";
        symbol = "🌱 ";
        style = "bold #${palette.base0B}";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold #${palette.base0A}";
        conflicted = "🏳";
        up_to_date = "✓";
        untracked = "🤷";
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
        stashed = "📦";
        modified = "📝";
        staged = "[++($count)](#${palette.base0B})";
        renamed = "👅";
        deleted = "🗑";
      };

      git_state = {
        format = "[$state( $progress_current of $progress_total)]($style) ";
        style = "#${palette.base03}";
      };

      git_metrics = {
        added_style = "bold #${palette.base0D}";
        deleted_style = "bold #${palette.base08}";
        format = "[+$added]($added_style)/[-$deleted]($deleted_style) ";
      };

      # Language modules
      nodejs = {
        format = "via [⬢ $version](bold #${palette.base0B}) ";
        disabled = false;
      };

      python = {
        format = "via [🐍 $version $virtualenv](bold #${palette.base0A}) ";
        disabled = false;
      };

      golang = {
        format = "via [🐹 $version](bold #${palette.base0C}) ";
        disabled = false;
      };

      rust = {
        format = "via [⚙️ $version](bold #${palette.base09}) ";
        disabled = false;
      };

      docker_context = {
        format = "via [🐋 $context](#${palette.base0D} bold)";
        disabled = false;
      };

      # Time
      time = {
        disabled = false;
        format = "🕙[$time]($style) ";
        style = "#${palette.base05}";
        time_format = "%T";
      };

      # Fill
      fill = {
        symbol = " ";
      };

      # Battery (for laptops)
      battery = {
        full_symbol = "🔋";
        charging_symbol = "🔌";
        discharging_symbol = "⚡";

        display = [
          {
            threshold = 15;
            style = "bold #${palette.base08}";
          }
          {
            threshold = 50;
            style = "bold #${palette.base0A}";
          }
          {
            threshold = 80;
            style = "bold #${palette.base0B}";
          }
        ];
      };

      # Memory usage
      memory_usage = {
        disabled = false;
        threshold = -1;
        symbol = "💾 ";
        style = "bold dimmed #${palette.base0B}";
        format = "via $symbol[$ram( | $swap)]($style) ";
      };

    };
  };
}
