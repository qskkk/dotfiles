{ config, secrets, ... }:

{
  programs.zsh.shellAliases = {
    # Navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";

    # List files
    "l" = "eza -la --icons";
    "ll" = "eza -l --icons";
    "la" = "eza -la --icons";
    "lt" = "eza --tree --icons";
    "ls" = "eza --icons";

    # Git shortcuts
    "g" = "git";
    "ga" = "git add";
    "gaa" = "git add --all";
    "gc" = "git commit";
    "gcm" = "git commit -m";
    "gca" = "git commit -am";
    "gcb" = "git branch --show-current";
    "gco" = "git checkout";
    "gd" = "git diff";
    "gdc" = "git diff --cached";
    "gl" = "git log --oneline --graph --decorate";
    "gla" = "git log --oneline --graph --decorate --all";
    "gp" = "git push";
    "gpl" = "git pull";
    "gs" = "git status";
    "gst" = "git stash";
    "gstp" = "git stash pop";
    "gb" = "git branch";
    "gba" = "git branch -a";
    "gbd" = "git branch -d";
    "gbD" = "git branch -D";
    "grh" = "git reset --hard";
    "grs" = "git reset --soft";
    "grm" = "git reset --mixed";

    # System
    "h" = "history";
    "hg" = "history | grep";
    "pg" = "ps aux | grep";
    "c" = "clear";
    "e" = "exit";
    "q" = "exit";

    # File operations
    "cp" = "cp -i";
    "mv" = "mv -i";
    "rm" = "rm -i";
    "mkdir" = "mkdir -pv";

    # Network
    "ping" = "ping -c 5";
    "ports" = "lsof -i -P -n | grep LISTEN";
    "myip" = "curl -s https://ipinfo.io/ip";

    # System monitoring
    "top" = "btop";
    "htop" = "btop";
    "du" = "ncdu";
    "df" = "df -h";
    "free" = "vm_stat";

    # Development
    "vim" = "nvim";
    "vi" = "nvim";
    "python" = "python3";
    "pip" = "pip3";

    # Docker
    "d" = "docker";
    "dc" = "docker-compose";
    "dps" = "docker ps";
    "dpsa" = "docker ps -a";
    "di" = "docker images";

    # Kubernetes
    "k" = "kubectl";
    "kgp" = "kubectl get pods";
    "kgs" = "kubectl get services";
    "kgd" = "kubectl get deployments";
    "kgn" = "kubectl get nodes";
    "kdp" = "kubectl describe pod";
    "kds" = "kubectl describe service";
    "kdd" = "kubectl describe deployment";

    # Nix
    "ns" = "nix-shell";
    "nb" = "nix-build";
    "nf" = "nix flake";
    "nr" = "nix run";
    "nix-gc" = "nix-collect-garbage -d";

    # AeroSpace management
    "aerorestart" = "bash ~/.scripts/aerospace_restart.sh";
    "aeroreload" = "aerospace reload-config";
    "aerostatus" =
      "pgrep -f AeroSpace && echo 'AeroSpace is running' || echo 'AeroSpace is not running'";

    # Darwin rebuild
    "nbuild" = "sudo darwin-rebuild switch --flake ~/workspace/perso/dotfiles/. --impure";
    "rebuild" = "darwin-rebuild switch --flake .";
    "rebuild-debug" = "darwin-rebuild switch --flake . --show-trace --verbose";

    # macOS specific
    "showfiles" = "defaults write com.apple.Finder AppleShowAllFiles true && killall Finder";
    "hidefiles" = "defaults write com.apple.Finder AppleShowAllFiles false && killall Finder";
    "sleepnow" = "pmset sleepnow";
    "restart" = "sudo shutdown -r now";
    "shutdown" = "sudo shutdown -h now";

    # Quick edits
    "zshrc" = "nvim ~/.zshrc";
    "vimrc" = "nvim ~/.config/nvim/init.lua";
    "sshconfig" = "nvim ~/.ssh/config";
    "hosts" = "sudo nvim /etc/hosts";

    # Utility
    "weather" = "curl wttr.in";
    "clock" = "while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-29));date;tput rc;done &";
    "timer" = "echo 'Timer started. Stop with Ctrl+C.' && date && time cat && date";
    "path" = "echo $PATH | tr ':' '\\n'";
    "reload" = "source ~/.zshrc";

    # Quick navigation to common directories
    "cddf" = "cd ~/.config/dotfiles";
    "cdnv" = "cd ~/.config/nvim";
    "cdws" = "cd ~/workspace";
    "cddl" = "cd ~/Downloads";
    "cddt" = "cd ~/Desktop";
    "cddoc" = "cd ~/Documents";

    # New aliases
    "gr" = "gr";
    "dcu" = "docker compose up";
    "dcb" = "docker compose build";
    "dcud" = "docker compose up -d";
    "de" = "docker exec";
    "dcd" = "docker compose down";
    "dcp" = "docker container prune";
    "dip" = "docker image prune";
    "dvp" = "docker volume prune";
    "ddb" = "cd $WORKSPACE/databases && dcud && cd -";
    "sshk" =
      let
        sshKeyCommands = builtins.map (key: "ssh-add -k ~/.ssh/${key}") (secrets.sshKeys or [ ]);
      in
      builtins.concatStringsSep " && " sshKeyCommands;
    "sshdid" = "ssh ${secrets.servers.prod or "user@your-server"}";
    "logj" = "dlogj $(basename \"$PWD\")";
    "log" = "dlog $(basename \"$PWD\")";
    "gol" = "goland . &";
  };

  programs.zsh.initContent =
    let
      workspace = secrets.workspaceUrl or "~/workspace/example/backend";
      githubOrg = secrets.githubOrg or "example";
      projects =
        secrets.projects or [
          "project1"
          "project2"
        ];

      # Generate sscall function with all projects
      sscallProjects = builtins.map (proj: "cd ${workspace}/${proj} && dcud") projects;
      sscallCmd = builtins.concatStringsSep " && " sscallProjects + " && cd -";

      # Generate ssdall function with all projects
      ssdallProjects = builtins.map (proj: "cd ${workspace}/${proj} && dcd") projects;
      ssdallCmd = builtins.concatStringsSep " && " ssdallProjects + " && cd -";
    in
    ''
      dlog () { docker logs -f $1; }
      kbash () { kubectl exec -it $1 bash; }
      dbash () { docker exec -it $1 bash; }
      dsh () { docker exec -it $1 sh; }
      ksh () { kubectl exec -it $1 sh; }
      goto () { cd ${workspace}/$1 ;}
      suso () {br=$(git branch | awk '/\*/ { print $2; }') && git branch --set-upstream-to=origin/$br $br ;}
      ssc () {cd ${workspace}/$1 && dcud && cd -;}
      sscall () {${sscallCmd};}
      ssdall () {${ssdallCmd};}
      sres (){gr @main sed -i \'\' -e '$a\\' go.mod && go mod tidy;}
      pr () {
          REMOTE=$(git remote get-url origin | sed 's#git@github.com:#https://github.com/#' | sed 's/\.git$//')
          open $REMOTE/pull/$(git branch --show-current);
      }
    '';
}
