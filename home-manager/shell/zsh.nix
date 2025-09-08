{
  config,
  pkgs,
  secrets,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History configuration
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };

    # Shell options
    defaultKeymap = "emacs";

    # Environment variables
    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      GOPATH = "/Users/${config.home.username}/go";
      GOPRIVATE = secrets.goprivate or "github.com/example";

      # Color variables
      ORANGE_COLOR = "#F5A97F";
      PURPLE_COLOR = "#C6A0F6";
      GREEN_COLOR = "#A6DA95";
      BLUE_COLOR = "#B7BDF8";
    };

    # PATH additions
    shellAliases = {
      # Docker shortcuts
      dlog = "docker logs -f";
      dsh = "docker exec -it";

      # Kubernetes shortcuts
      kbash = "kubectl exec -it";
      ksh = "kubectl exec -it";

      # Custom scripts
      prodc = "bash ~/.scripts/prodc.sh";
      commit = "bash ~/.scripts/commit.sh";

      # Common shortcuts
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    # Shell integrations
    initContent = ''
            cat << 'EOF'
                                      *     *
                                     ( \---/ )
                                      ) . . (
        ________________________,--._(___Y___)_,--._______________________
                                `--'           `--'
                          ██████     █████████  █████   ████
                        ███░░░░███  ███░░░░░███░░███   ███░
                       ███    ░░███░███    ░░░  ░███  ███
                      ░███     ░███░░█████████  ░███████
                      ░███   ██░███ ░░░░░░░░███ ░███░░███
                      ░░███ ░░████  ███    ░███ ░███ ░░███
                       ░░░██████░██░░█████████  █████ ░░████
                         ░░░░░░ ░░  ░░░░░░░░░  ░░░░░   ░░░░
      EOF

            # Zoxide integration
            eval "$(zoxide init zsh)"

            # FZF integration
            source ${pkgs.fzf}/share/fzf/key-bindings.zsh
            source ${pkgs.fzf}/share/fzf/completion.zsh

            # Custom functions
            function mkcd() {
              mkdir -p "$1" && cd "$1"
            }

            function extract() {
              if [ -f $1 ] ; then
                case $1 in
                  *.tar.bz2)   tar xjf $1     ;;
                  *.tar.gz)    tar xzf $1     ;;
                  *.bz2)       bunzip2 $1     ;;
                  *.rar)       unrar e $1     ;;
                  *.gz)        gunzip $1      ;;
                  *.tar)       tar xf $1      ;;
                  *.tbz2)      tar xjf $1     ;;
                  *.tgz)       tar xzf $1     ;;
                  *.zip)       unzip $1       ;;
                  *.Z)         uncompress $1  ;;
                  *.7z)        7z x $1        ;;
                  *)     echo "'$1' cannot be extracted via extract()" ;;
                esac
              else
                echo "'$1' is not a valid file"
              fi
            }

            # Git quick status
            function gs() {
              git status --porcelain | while read status file; do
                case $status in
                  'M ') echo "📝 $file" ;;
                  'A ') echo "➕ $file" ;;
                  'D ') echo "🗑️  $file" ;;
                  'R ') echo "📛 $file" ;;
                  '??') echo "❓ $file" ;;
                  *) echo "$status $file" ;;
                esac
              done
            }

            # Workspace functions
            WORKSPACE=${secrets.workspaceUrl or "~/workspace/example/backend"}

            function dlog() { docker logs -f $1; }
            function kbash() { kubectl exec -it $1 bash; }
            function dsh() { docker exec -it $1 sh; }
            function ksh() { kubectl exec -it $1 sh; }
            function goto() {cd $(gf goto "$1")}
            function suso() {
              br=$(git branch | awk '/\*/ { print $2; }') && git branch --set-upstream-to=origin/$br $br;
            }
            function ssc() { cd $WORKSPACE/$1 && dcud && cd -; }
            function sres() { gr @main sed -i \'\' -e '$a\' go.mod && go mod tidy; }
            function pr() {
              open https://github.com/${secrets.githubOrg or "example"}/$(basename "$PWD")/pull/$(git branch --show-current);
            }

            tb
    '';
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];

    # File search
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=header,grid --line-range :300 {}'"
    ];

    # Directory search
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];

    # History search
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };

  # Zoxide configuration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
