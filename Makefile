WALLPAPER ?= 803.jpg
COLOR ?= pink

switch:
	sudo darwin-rebuild switch --flake ~/workspace/perso/dotfiles/. --impure

wall-pink:
	@make sw WALLPAPER=pink.jpg COLOR=pink THEME=rose-pine-moon

wall-blue:
	@make sw WALLPAPER=blue.jpg COLOR=blue THEME=catppuccin-mocha

wall-green:
	@make sw WALLPAPER=green.jpg COLOR=green THEME=everforest

wall-rand:
	$(eval WALLPAPER := $(shell basename $(shell find assets -type f -name '*.jpg' | awk 'BEGIN{srand();}{print rand()"\t"$$0}' | sort -k1,1n | cut -f2- | head -n1)))
	$(eval COLOR := $(shell basename $(WALLPAPER) .jpg))
	@make sw WALLPAPER=$(WALLPAPER) COLOR=$(COLOR)

sw:
	@echo "Setting wallpaper to $(WALLPAPER) ($(COLOR))"
	@sed -i '' 's|wallpaperPath = ".*";|wallpaperPath = "assets/$(WALLPAPER)";|' secrets.nix
	@echo "Wallpaper path updated to assets/$(WALLPAPER)"
	@sed -i '' 's|theme = ".*";|theme = "$(THEME)";|' secrets.nix
