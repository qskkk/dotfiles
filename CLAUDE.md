# Dotfiles — Claude Guidelines

## Project structure

- `flake.nix` — entry point, defines Darwin and NixOS configurations
- `darwin-configuration.nix` — macOS system-level config
- `home-manager/` — user-level config (programs, shell, git)
- `home-manager/programs/` — per-app `.nix` files
- `pkgs/` — custom package derivations
- `secrets.nix` — machine-specific values (gitignored), see `secrets.nix.example`

## Apply changes

```bash
make switch   # darwin-rebuild switch --flake . --impure
```

## Nix best practices

### Flake hygiene
- All inputs must have `follows = "nixpkgs"` to avoid duplicate nixpkgs versions
- Pin inputs with `nix flake update` intentionally, not automatically
- Use `--impure` only when reading from the filesystem (e.g. secrets)

### Module style
- Prefer `home-manager` options (`programs.<name>.enable`) over raw `home.packages` when a module exists
- Pass shared values (`username`, `secrets`, `nix-colors`) via `specialArgs`, not inline
- Use `let ... in` blocks to avoid repeating values within a file
- Keep per-app config in its own file under `home-manager/programs/` and import via `default.nix`

### Packages
- Default to `nixpkgs-unstable` for bleeding-edge tools
- Custom derivations go in `pkgs/` and are exposed as overlays or direct references
- Use overlays in `flake.nix` for global package overrides (e.g. forcing `nodejs_22`)

### Secrets
- Never commit `secrets.nix` — use `secrets.nix.example` as the template
- Reference secrets via `specialArgs` so modules stay pure and testable

### Formatting & linting
- Format with `nixfmt` or `alejandra` before committing
- Avoid `with pkgs;` in module files — prefer explicit `pkgs.<name>` for clarity
