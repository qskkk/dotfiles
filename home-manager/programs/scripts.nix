{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Personal scripts
  home.file.".scripts/commit.sh" = {
    text = ''
      #!/bin/bash

      # Generate code and fix go mod
      if [ -e "go.mod" ]; then
          gum confirm "Wanna Go generate?" && \
           gum spin --spinner monkey --title "Go generate ..." -- go generate ./...

          gum spin --spinner monkey --title "Go mod tidy ..." -- go mod tidy

          # Run tests
          gum spin --show-output --spinner monkey --title "Go test ..." -- go test ./...
          if [ $? -ne 0 ]; then
              if ! gum confirm "Tests failed. Do you really want to commit?"; then
                  exit 1
              fi
          fi
      fi

      if [ -f "Makefile" ]; then
          if grep -q "^doc:" Makefile; then
              gum confirm "Wanna Swagger generate?" && \
                  sudo echo "sudo access granted" && \
                   gum spin --spinner monkey --title "Swagger generate ..." -- make doc
          fi

          if grep -q "^deadcode:" Makefile; then
              output=$(gum spin --spinner monkey --title "Checking deadcode ..." -- make deadcode)
                 if [ $? -ne 0 ]; then
                  if ! gum confirm "Deadcode detected. Do you really want to commit?"; then
                      exit 1
                  fi
              fi
          fi
      fi

      git add .

      # Make commit
      TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
      SCOPE=$(gum input --placeholder "scope")

      # Since the scope is optional, wrap it in parentheses if it has a value.
      test -n "$SCOPE" && SCOPE="($SCOPE)"

      # Pre-populate the input with the type(scope): so that the user may change it
      SUMMARY=$(gum input --value "$TYPE$SCOPE: " --placeholder "Summary of this change")
      DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")

      # Commit these changes
      gum confirm "Commit changes?" && \
       git commit -m "$SUMMARY" -m "$DESCRIPTION" && \
        gum confirm "Push changes?" && \
         gum spin --show-output --spinner monkey --title "Pushing changes ..." -- git push
    '';
    executable = true;
  };

  home.file.".scripts/prodc.sh" = {
    text = ''
      #!/usr/bin/env bash

      CHOICE=$(gum choose --no-limit "all" "marcus" "hachiko" "gunther" "capitan" "tracker" "owney" "chase")
      OPEN=$(gum choose "yes" "no")

      github_prefix="https://github.com/japhy-team/"

      if [ -z "$CHOICE" ]; then
        CHOICE="all"
      fi

      declare -A envs=(
              ["marcus"]="marcus-production-arm"
              ["hachiko"]="hachiko-production-arm"
              ["gunther"]="gunther-production-arm"
              ["capitan"]="capitan-production-arm-fr"
              ["tracker"]="tracker-production-arm"
              ["owney"]="owney-production"
              ["chase"]="chase-production"
          )

      declare -A environments

      while IFS= read -r line; do
          if [ $line = "all" ]; then
              for key in "''${!envs[@]}"; do
                  environments[$key]="''${envs[$key]}"
              done
              continue
          else
              environments[$line]=''${envs[$line]}
          fi
      done <<< "$CHOICE"

      for repo in "''${!environments[@]}"; do
          env_name=''${environments[$repo]}
          version=$(gum spin --spinner monkey --show-output --title "Fetching production version for $repo ..." -- aws elasticbeanstalk describe-environments --environment-names $env_name --query "Environments[0].VersionLabel" --output text)
          url="''${github_prefix}''${repo}/compare/''${version#production_}...main"
          echo "''${repo}: ''${url}"

          if [ $OPEN = "yes" ]; then
              open $url & disown
          fi
      done
    '';
    executable = true;
  };

  # Script to refresh Warp theme
  home.file.".scripts/refresh-warp-theme.sh" = {
    text = ''
      #!/bin/bash
      echo "Refreshing Warp theme..."
      /usr/bin/pkill -f "Warp" || true
      sleep 1
      /usr/bin/open -a Warp
    '';
    executable = true;
  };

  # Script to rebuild nix-darwin configuration
  home.file.".scripts/nbuild.sh" = {
    text = ''
      #!/bin/bash

      # Display notification that rebuild is starting
      /usr/bin/osascript -e 'display notification "Starting nix-darwin rebuild..." with title "Nix Darwin"' 2>/dev/null || true

      # Change to dotfiles directory
      cd "$HOME/workspace/perso/dotfiles" || exit 1

      # Run the rebuild command
      if nbuild; then
        /usr/bin/osascript -e 'display notification "Rebuild completed successfully!" with title "Nix Darwin"' 2>/dev/null || true
      else
        /usr/bin/osascript -e 'display notification "Rebuild failed! Check terminal for errors." with title "Nix Darwin"' 2>/dev/null || true
      fi
    '';
    executable = true;
  };
}
