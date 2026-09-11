{
  pkgs,
  lib,
  ...
}:

{
  # OpenAI Codex CLI.
  #
  # Installé via npm et non via pkgs.codex : nixpkgs traîne derrière les
  # releases upstream, qui sortent plusieurs fois par semaine.
  #
  # Pas non plus dans la liste NPM_PACKAGES de home.nix : cette boucle-là
  # skippe tout paquet déjà installé, donc elle ne met jamais à jour. Ici on
  # compare la version installée à celle du registre à chaque switch.
  #
  # La config vit dans ~/.codex/ et est gérée par ChatGPT.app — on ne la
  # déclare pas ici (cf. claude.nix, désactivé pour cette raison).
  home.activation.installCodex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"

    current=$(${pkgs.jq}/bin/jq -r '.version // empty' \
      "$NPM_CONFIG_PREFIX/lib/node_modules/@openai/codex/package.json" 2>/dev/null || true)
    latest=$(${pkgs.nodejs}/bin/npm view @openai/codex version 2>/dev/null || true)

    if [ -z "$latest" ]; then
      # Hors ligne ou registre injoignable : on ne casse pas le switch.
      echo "@openai/codex: registre injoignable, version locale conservée (''${current:-aucune})"
    elif [ "$current" != "$latest" ]; then
      echo "@openai/codex: ''${current:-aucune} -> $latest"
      $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install -g "@openai/codex@$latest" || true
    else
      echo "@openai/codex: déjà à jour ($current)"
    fi
  '';
}
