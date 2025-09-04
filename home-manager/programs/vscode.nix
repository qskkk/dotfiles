{
  config,
  pkgs,
  colorScheme,
  ...
}:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      # Extensions
      extensions = with pkgs.vscode-extensions; [
        # Language support
        # vscodevim.vim
        ms-python.python
        golang.go
        rust-lang.rust-analyzer

        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        eamodio.gitlens
        esbenp.prettier-vscode
        github.copilot
        github.copilot-chat
        golang.go
        jnoortheen.nix-ide
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-python.python
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vsliveshare.vsliveshare
        usernamehw.errorlens

        # Nix
        bbenoist.nix

        # Git
        eamodio.gitlens

        # Themes
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons

        # Productivity
        ms-vscode-remote.remote-ssh
        ms-vsliveshare.vsliveshare

        # Formatting
        esbenp.prettier-vscode

        # Other useful extensions
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-vscode-remote.remote-containers
        github.copilot
        github.copilot-chat
      ];

      # User settings synchronized with nix-colors colorScheme
      userSettings = {
        # Use Default theme as base and override with colorScheme colors
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
        "workbench.preferredHighContrastColorTheme" = "Catppuccin Mocha";
        "workbench.preferredHighContrastLightColorTheme" = "Catppuccin Late";
        "workbench.iconTheme" = "vs-seti";

        # Custom color overrides using nix-colors
        "workbench.colorCustomizations" = {
          "editor.background" = "#${colorScheme.palette.base00}";
          "editor.foreground" = "#${colorScheme.palette.base05}";
          "activityBar.background" = "#${colorScheme.palette.base01}";
          "activityBar.foreground" = "#${colorScheme.palette.base05}";
          "activityBar.inactiveForeground" = "#${colorScheme.palette.base04}";
          "sideBar.background" = "#${colorScheme.palette.base01}";
          "sideBar.foreground" = "#${colorScheme.palette.base05}";
          "sideBar.border" = "#${colorScheme.palette.base02}";
          "statusBar.background" = "#${colorScheme.palette.base02}";
          "statusBar.foreground" = "#${colorScheme.palette.base05}";
          "statusBar.border" = "#${colorScheme.palette.base02}";
          "terminal.background" = "#${colorScheme.palette.base00}";
          "terminal.foreground" = "#${colorScheme.palette.base05}";
          "panel.background" = "#${colorScheme.palette.base01}";
          "panel.border" = "#${colorScheme.palette.base02}";
          "titleBar.activeBackground" = "#${colorScheme.palette.base02}";
          "titleBar.activeForeground" = "#${colorScheme.palette.base05}";
          "titleBar.inactiveBackground" = "#${colorScheme.palette.base01}";
          "titleBar.inactiveForeground" = "#${colorScheme.palette.base04}";
          "tab.activeBackground" = "#${colorScheme.palette.base00}";
          "tab.activeForeground" = "#${colorScheme.palette.base05}";
          "tab.inactiveBackground" = "#${colorScheme.palette.base01}";
          "tab.inactiveForeground" = "#${colorScheme.palette.base04}";
          "tab.border" = "#${colorScheme.palette.base02}";
          "editorGroupHeader.tabsBackground" = "#${colorScheme.palette.base01}";
          "input.background" = "#${colorScheme.palette.base02}";
          "input.foreground" = "#${colorScheme.palette.base05}";
          "input.border" = "#${colorScheme.palette.base03}";
          "dropdown.background" = "#${colorScheme.palette.base01}";
          "dropdown.foreground" = "#${colorScheme.palette.base05}";
          "dropdown.border" = "#${colorScheme.palette.base03}";
          "list.activeSelectionBackground" = "#${colorScheme.palette.base02}";
          "list.activeSelectionForeground" = "#${colorScheme.palette.base05}";
          "list.hoverBackground" = "#${colorScheme.palette.base02}";
          "list.focusBackground" = "#${colorScheme.palette.base02}";
          "button.background" = "#${colorScheme.palette.base0D}";
          "button.foreground" = "#${colorScheme.palette.base00}";
          "button.hoverBackground" = "#${colorScheme.palette.base0C}";
          "scrollbar.shadow" = "#${colorScheme.palette.base01}";
          "scrollbarSlider.background" = "#${colorScheme.palette.base02}";
          "scrollbarSlider.hoverBackground" = "#${colorScheme.palette.base03}";
          "scrollbarSlider.activeBackground" = "#${colorScheme.palette.base04}";
          "progressBar.background" = "#${colorScheme.palette.base0D}";
          "widget.shadow" = "#${colorScheme.palette.base01}";
          "editorWidget.background" = "#${colorScheme.palette.base01}";
          "editorWidget.border" = "#${colorScheme.palette.base02}";
          "pickerGroup.border" = "#${colorScheme.palette.base02}";
          "pickerGroup.foreground" = "#${colorScheme.palette.base0D}";
          "debugToolBar.background" = "#${colorScheme.palette.base01}";
          "debugToolBar.border" = "#${colorScheme.palette.base02}";
          "notifications.background" = "#${colorScheme.palette.base01}";
          "notifications.foreground" = "#${colorScheme.palette.base05}";
          "notifications.border" = "#${colorScheme.palette.base02}";
          "notificationsErrorIcon.foreground" = "#${colorScheme.palette.base08}";
          "notificationsWarningIcon.foreground" = "#${colorScheme.palette.base0A}";
          "notificationsInfoIcon.foreground" = "#${colorScheme.palette.base0D}";
          "menubar.selectionBackground" = "#${colorScheme.palette.base02}";
          "menubar.selectionForeground" = "#${colorScheme.palette.base05}";
          "menu.background" = "#${colorScheme.palette.base01}";
          "menu.foreground" = "#${colorScheme.palette.base05}";
          "menu.selectionBackground" = "#${colorScheme.palette.base02}";
          "menu.selectionForeground" = "#${colorScheme.palette.base05}";
          "menu.separatorBackground" = "#${colorScheme.palette.base02}";
          "editorLineNumber.foreground" = "#${colorScheme.palette.base03}";
          "editorLineNumber.activeForeground" = "#${colorScheme.palette.base05}";
          "editorCursor.foreground" = "#${colorScheme.palette.base05}";
          "editor.selectionBackground" = "#${colorScheme.palette.base02}";
          "editor.lineHighlightBackground" = "#${colorScheme.palette.base01}";
          "editorIndentGuide.background" = "#${colorScheme.palette.base02}";
          "editorIndentGuide.activeBackground" = "#${colorScheme.palette.base03}";
          "editorRuler.foreground" = "#${colorScheme.palette.base02}";
          "editorBracketMatch.background" = "#${colorScheme.palette.base02}";
          "editorBracketMatch.border" = "#${colorScheme.palette.base03}";
        };

        # Editor syntax highlighting colors using nix-colors
        "editor.tokenColorCustomizations" = {
          "textMateRules" = [
            {
              "scope" = [
                "comment"
                "punctuation.definition.comment"
              ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base03}";
                "fontStyle" = "italic";
              };
            }
            {
              "scope" = [
                "string"
                "string.quoted"
                "string.template"
              ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base0B}";
              };
            }
            {
              "scope" = [
                "constant.numeric"
                "constant.language"
                "constant.character.escape"
              ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base09}";
              };
            }
            {
              "scope" = [
                "keyword"
                "storage.type"
                "storage.modifier"
              ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base0E}";
              };
            }
            {
              "scope" = [
                "entity.name.function"
                "support.function"
              ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base0D}";
              };
            }
            {
              "scope" = [
                "entity.name.class"
                "entity.name.type"
                "support.class"
              ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base0A}";
              };
            }
            {
              "scope" = [
                "variable"
                "variable.parameter"
                "variable.other"
              ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base08}";
              };
            }
            {
              "scope" = [ "entity.name.tag" ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base08}";
              };
            }
            {
              "scope" = [ "entity.other.attribute-name" ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base0A}";
              };
            }
            {
              "scope" = [ "support.type.property-name" ];
              "settings" = {
                "foreground" = "#${colorScheme.palette.base0C}";
              };
            }
          ];
        };

        # Terminal colors using nix-colors
        "terminal.integrated.colorScheme" = "dark";
        "terminal.integrated.profiles.osx" = {
          "zsh" = {
            "path" = "zsh";
            "args" = [ "-l" ];
          };
        };
        "workbench.editor.openPositioning" = "left";
        "workbench.editor.showTabs" = "none";

        "editor.accessibilitySupport" = "on";
        "editor.minimap.enabled" = false;
        "editor.fontSize" = 14;
        "editor.fontFamily" = "Fira Code, Hack Nerd Font Mono, Menlo, Monaco, 'Courier New', monospace";
        "editor.fontLigatures" = true;
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.fixAll" = "explicit";
          "source.fixAll.eslint" = "explicit";
        };
        "editor.defaultFormatter" = "esbenp.prettier-vscode";

        "editor.cursorSmoothCaretAnimation" = "on";

        # use Cmd+clic for "Go to Definition"
        "editor.multiCursorModifier" = "alt";
        "editor.gotoLocation.multipleReferences" = "gotoAndPeek";
        "editor.gotoLocation.multipleDefinitions" = "gotoAndPeek";
        "editor.gotoLocation.multipleDeclarations" = "gotoAndPeek";
        "editor.gotoLocation.multipleImplementations" = "gotoAndPeek";

        "github.copilot.nextEditSuggestions.enabled" = true;
        "githubPullRequests.pullBranch" = "never";
        "githubPullRequests.fileListLayout" = "flat";
        "githubPullRequests.queries" = [
          {
            label = "Local Pull Request Branches";
            query = "default";
          }
          {
            label = "Waiting For My Review";
            query = "repo:\${owner}/\${repository} is:open review-requested:\${user}";
          }
          {
            label = "all request";
            query = "repo:\${owner}/\${repository} is:pr is:open review-requested:\${user} archived:false ";
          }
          {
            label = "All Open";
            query = "default";
          }
        ];

        "camouflage.enabled" = false;
        "liveshare.accessibility.soundsEnabled" = false;
        "accessibility.signals.lineHasError" = {
          "sound" = "off";
        };
        "accessibility.signalOptions.volume" = 0;
        "go.testExplorer.alwaysRunBenchmarks" = true;
        "security.promptForLocalFileProtocolHandling" = false;
        "files.autoSave" = "onFocusChange";
        "chat.editing.confirmEditRequestRetry" = false;
        "eslint.format.enable" = true;
        "eslint.validate" = [
          "javascript"
          "typescript"
          "typescriptreact"
          "vue"
        ];
        "eslint.run" = "onSave";

        "[jsonc]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[vue]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };

        # Configuration Go
        "[go]" = {
          "editor.defaultFormatter" = "golang.go";
          "editor.formatOnSave" = true;
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = true;
          };
        };

        "go.formatTool" = "gofmt";
        "go.toolsManagement.autoUpdate" = true;

        # Configuration Go pour navigation interface/implémentation
        "go.gotoSymbol.includeImports" = true;
        "go.gotoSymbol.includeGoroot" = true;
        "go.enableCodeLens" = {
          "references" = true;
          "runtest" = true;
        };
        "go.showWelcome" = false;
        "go.survey.prompt" = false;

        # Configuration Vim
        "vim.easymotion" = true;
        "vim.incsearch" = true;
        "vim.useSystemClipboard" = true;
        "vim.useCtrlKeys" = true;
        "vim.hlsearch" = true;
        "vim.insertModeKeyBindings" = [
          {
            before = [
              "j"
              "j"
            ];
            after = [ "<Esc>" ];
          }
        ];
        "vim.normalModeKeyBindingsNonRecursive" = [
          {
            before = [
              "<leader>"
              "d"
            ];
            after = [
              "d"
              "d"
            ];
          }
          {
            before = [ "<C-n>" ];
            commands = [ ":nohl" ];
          }
        ];
        "vim.leader" = "<space>";
        "vim.handleKeys" = {
          "<C-a>" = false;
          "<C-f>" = false;
          "<C-c>" = false;
          "<C-v>" = false;
          "<C-x>" = false;
          "<C-z>" = false;
        };
      };

      # Keybindings
      keybindings = [
        {
          key = "cmd+shift+e";
          command = "workbench.view.explorer";
          when = "viewContainer.workbench.view.explorer.enabled";
        }
        {
          key = "cmd+shift+f";
          command = "workbench.view.search";
          when = "workbench.view.search.active && neverMatch =~ /doesNotMatch/";
        }
        {
          key = "cmd+shift+g";
          command = "workbench.view.scm";
          when = "workbench.scm.active";
        }
        {
          key = "cmd+shift+d";
          command = "workbench.view.debug";
          when = "viewContainer.workbench.view.debug.enabled";
        }
        {
          key = "cmd+shift+x";
          command = "workbench.view.extensions";
          when = "viewContainer.workbench.view.extensions.enabled";
        }
        {
          key = "cmd+j";
          command = "workbench.action.togglePanel";
        }
        {
          key = "cmd+shift+c";
          command = "workbench.action.terminal.openNativeConsole";
          when = "!terminalFocus";
        }
        {
          key = "cmd+k cmd+t";
          command = "workbench.action.selectTheme";
        }

        # JetBrains/GoLand style keybindings (Mac)
        {
          key = "cmd+shift+a";
          command = "workbench.action.showCommands";
        } # Find Action
        {
          key = "cmd+o";
          command = "workbench.action.quickOpen";
        } # Go to File
        {
          key = "cmd+shift+o";
          command = "workbench.action.gotoSymbol";
        } # Go to Symbol in File
        {
          key = "cmd+e";
          command = "workbench.action.openRecent";
        } # Recent Files
        {
          key = "cmd+b";
          command = "editor.action.revealDefinition";
        } # Go to Definition
        {
          key = "cmd+alt+b";
          command = "editor.action.goToImplementation";
        } # Go to Implementation
        {
          key = "cmd+shift+f12";
          command = "references-view.findReferences";
        } # Find All References
        {
          key = "cmd+alt+f12";
          command = "references-view.findImplementations";
        } # Find All Implementations
        {
          key = "cmd+u";
          command = "editor.action.goToSuperImplementation";
        } # Go to Super Method
        {
          key = "cmd+f12";
          command = "workbench.action.gotoSymbol";
        } # File Structure
        {
          key = "cmd+/";
          command = "editor.action.commentLine";
        } # Toggle Line Comment
        {
          key = "cmd+alt+l";
          command = "editor.action.formatDocument";
        } # Reformat Code
        {
          key = "shift+f6";
          command = "editor.action.rename";
        } # Rename
        {
          key = "shift+f6";
          command = "renameFile";
          when = "explorerViewletVisible && filesExplorerFocus && !inputFocus";
        }
        {
          key = "f2";
          command = "editor.action.marker.next";
        } # Next Error/Warning
        {
          key = "shift+f2";
          command = "editor.action.marker.prev";
        } # Previous Error/Warning
        {
          key = "cmd+d";
          command = "editor.action.copyLinesDownAction";
        } # Duplicate Line
        {
          key = "cmd+delete";
          command = "editor.action.deleteLines";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "cmd+y";
          command = "editor.action.copyLinesDownAction";
        } # Duplicate Line (alternative)
        {
          key = "alt+shift+up";
          command = "editor.action.moveLinesUpAction";
        } # Move Line Up
        {
          key = "alt+shift+down";
          command = "editor.action.moveLinesDownAction";
        } # Move Line Down
        {
          key = "cmd+shift+u";
          command = "editor.action.transformToTitlecase";
        } # Toggle Case (Smart Transform)
        {
          key = "cmd+w";
          command = "workbench.action.closeActiveEditor";
        } # Close Editor
        {
          key = "cmd+alt+left";
          command = "workbench.action.navigateBack";
        } # Navigate Back
        {
          key = "cmd+alt+right";
          command = "workbench.action.navigateForward";
        } # Navigate Forward
        {
          key = "cmd+alt+o";
          command = "workbench.action.quickOpenPreviousRecentlyUsedEditor";
        } # Go to File (Recent)
        {
          key = "shift shift";
          command = "workbench.action.quickOpen";
        }
        {
          key = "ctrl+g";
          command = "editor.action.addSelectionToNextFindMatch";
        } # Select next occurrence
        {
          key = "cmd+click";
          command = "references-view.findReferences";
          when = "editorTextFocus";
        }
        {
          key = "cmd+r";
          command = "editor.action.startFindReplaceAction";
          when = "editorFocus || editorIsOpen";
        } # Find and Replace in File
        {
          key = "cmd+shift+r";
          command = "workbench.action.replaceInFiles";
        }
      ];
    }; # End of profiles.default
  };
}
