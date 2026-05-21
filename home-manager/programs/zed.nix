{
  config,
  pkgs,
  colorScheme,
  ...
}:

{
  # Zed settings — migrated from vscode.nix
  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    # Theme
    theme = {
      mode = "dark";
      dark = "Catppuccin Mocha";
      light = "Catppuccin Latte";
    };

    # Font
    buffer_font_family = "Fira Code";
    buffer_font_size = 14;
    buffer_font_features = {
      calt = true; # ligatures
    };
    ui_font_family = "Hack Nerd Font Mono";
    ui_font_size = 14;

    # Editor
    tab_size = 2;
    format_on_save = "on";
    autosave = {
      after_delay = {
        milliseconds = 500;
      };
    };
    cursor_blink = false;
    smooth_scrolling = true;
    show_whitespaces = "selection";
    minimap = {
      show = "never";
    };
    scrollbar = {
      show = "auto";
    };
    tabs = {
      close_position = "right";
      file_icons = true;
      git_status = true;
    };
    indent_guides = {
      enabled = true;
    };
    inlay_hints = {
      enabled = true;
    };

    # Terminal
    terminal = {
      shell = {
        with_arguments = {
          program = "zsh";
          args = [ "-l" ];
        };
      };
      font_family = "Hack Nerd Font Mono";
      font_size = 14;
    };

    # Vim mode
    vim_mode = true;
    vim = {
      use_system_clipboard = "always";
    };

    # Copilot / AI
    edit_predictions = {
      provider = "copilot";
    };
    agent = {
      enabled = true;
      dock = "right";
    };

    # Claude Agent (ACP) — https://zed.dev/docs/ai/external-agents#claude-agent
    agent_servers = {
      claude-acp = {
        type = "registry";
      };
    };

    # Panels — folder on the left, agent on the right
    project_panel = {
      dock = "left";
    };

    # Extensions
    auto_install_extensions = {
      claude-code = true;
    };

    # Telemetry
    telemetry = {
      diagnostics = false;
      metrics = false;
    };

    # Git
    git = {
      inline_blame = {
        enabled = true;
      };
    };

    # Languages
    languages = {
      Go = {
        tab_size = 4;
        format_on_save = "on";
        code_actions_on_format = {
          "source.organizeImports" = true;
        };
      };
      Nix = {
        formatter = {
          external = {
            command = "nixfmt";
          };
        };
      };
      JSON = {
        format_on_save = "off";
      };
      JSONC = {
        format_on_save = "off";
      };
      Vue = {
        formatter = {
          external = {
            command = "prettier";
            arguments = [ "--parser" "vue" ];
          };
        };
      };
      JavaScript = {
        formatter = {
          external = {
            command = "prettier";
            arguments = [ "--parser" "babel" ];
          };
        };
      };
      TypeScript = {
        formatter = {
          external = {
            command = "prettier";
            arguments = [ "--parser" "typescript" ];
          };
        };
      };
    };

    # File scan exclusions
    file_scan_exclusions = [
      "**/.git"
      "**/.svn"
      "**/node_modules"
      "**/tmp"
      "**/.DS_Store"
    ];

    # Trust all projects by default
    project_trust = "always_trust";

    # Use JetBrains keymap as base
    base_keymap = "JetBrains";
  };

  # Zed keymap — custom overrides on top of JetBrains base keymap
  xdg.configFile."zed/keymap.json".text = builtins.toJSON [
    {
      context = "Editor";
      bindings = {
        "cmd-delete" = "editor::DeleteLine";
        "ctrl-g" = "editor::SelectNext";
      };
    }
    {
      context = "Workspace";
      bindings = {
        "cmd-j" = "workspace::ToggleBottomDock";
        "cmd-shift-e" = "workspace::ToggleLeftDock";
        "cmd-shift-f" = "pane::DeploySearch";
        "shift shift" = "file_finder::Toggle";
        "cmd-alt-c" = [
          "agent::NewExternalAgentThread"
          { agent = { custom = { name = "claude-acp"; }; }; }
        ];
      };
    }
    {
      context = "vim_mode == normal";
      bindings = {
        "space d" = "editor::DeleteLine";
      };
    }
    {
      context = "vim_mode == insert";
      bindings = {
        "j j" = "vim::NormalBefore";
      };
    }
  ];
}
