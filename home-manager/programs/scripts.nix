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

      # Load configuration from environment variables
      github_prefix="''${PRODC_GITHUB_PREFIX:-}"
      services_list="''${PRODC_SERVICES:-}"

      if [ -z "$github_prefix" ]; then
        echo "Error: PRODC_GITHUB_PREFIX environment variable is not set"
        exit 1
      fi

      if [ -z "$services_list" ]; then
        echo "Error: PRODC_SERVICES environment variable is not set"
        exit 1
      fi

      # Convert services list to array for gum choose
      IFS=' ' read -r -a services_array <<< "$services_list"

      CHOICE=$(gum choose --no-limit "all" "''${services_array[@]}")
      OPEN=$(gum choose "yes" "no")

      if [ -z "$CHOICE" ]; then
        CHOICE="all"
      fi

      # Build envs mapping from environment variables
      declare -A envs
      for service in ''${services_array[@]}; do
          service_upper=$(echo "$service" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
          env_var="PRODC_ENV_''${service_upper}"
          env_value="''${!env_var}"

          if [ -z "$env_value" ]; then
              echo "Error: Environment variable $env_var is not set for service $service"
              exit 1
          fi

          envs[$service]="$env_value"
      done

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
          latest_tag=$(gum spin --spinner monkey --show-output --title "Fetching latest tag for $repo ..." -- git ls-remote --tags --sort=-v:refname "''${github_prefix}''${repo}.git" | head -n1 | sed 's/.*refs\/tags\///' | sed 's/\^{}//' || echo "main")
          prod_version="''${version#production_}"
          url="''${github_prefix}''${repo}/compare/''${prod_version}...''${latest_tag}"

          if [ "$prod_version" != "$latest_tag" ]; then
              echo "''${repo}: ''${url} (''${prod_version} -> ''${latest_tag})"
              if [ $OPEN = "yes" ]; then
                  open $url & disown
              fi
          else
              echo "''${repo}: up to date (''${latest_tag})"
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

  # Script to prune old Time Machine backups
  home.file.".scripts/retention-time-machine.sh" = {
    text = ''
      #!/bin/bash
      # retention-time-machine.sh
      DAYS=60   # garde les 60 derniers jours (mets 30 pour 1 mois, 90 pour 3 mois)

      CUTOFF=$(date -v-''${DAYS}d +%Y-%m-%d)
      echo "Suppression des backups antérieurs au $CUTOFF"

      tmutil listbackups | while read backup; do
        # Extrait la date du chemin (format YYYY-MM-DD-HHMMSS)
        snapshot=$(basename "$backup" .backup)
        backup_date=$(echo "$snapshot" | cut -c1-10)
        if [[ "$backup_date" < "$CUTOFF" ]]; then
          # APFS Time Machine: backup path is <mount>/<timestamp>.backup/<timestamp>.backup
          mount=$(dirname "$(dirname "$backup")")
          echo "Suppression : $snapshot ($mount)"
          sudo tmutil delete -d "$mount" -t "$snapshot"
        fi
      done
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
      if sudo darwin-rebuild switch --flake path:.#Romains-MacBook-Pro --impure; then
        /usr/bin/osascript -e 'display notification "Rebuild completed successfully!" with title "Nix Darwin"' 2>/dev/null || true
      else
        /usr/bin/osascript -e 'display notification "Rebuild failed! Check terminal for errors." with title "Nix Darwin"' 2>/dev/null || true
      fi
    '';
    executable = true;
  };
}
