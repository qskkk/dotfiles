# NixOS Desktop Installation Guide

Guide d'installation de NixOS avec Hyprland depuis ces dotfiles.

## Pre-requis

- Cle USB avec l'ISO NixOS **minimal** (pas GNOME) depuis [nixos.org](https://nixos.org/download)
- Acces internet (ethernet recommande)

## 1. Boot sur l'ISO

Boot sur la cle USB. Une fois dans le terminal :

```bash
# Passer en Dvorak (optionnel)
loadkeys dvorak
```

## 2. Partitionnement

> Si le disque est deja partitionne, passer a l'etape 3.

```bash
# Voir les disques
lsblk

# Partitionner (remplacer nvme0n1 par ton disque)
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 1GB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart root ext4 1GB 100%

# Formater avec les bons labels
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.ext4 -L nixos /dev/nvme0n1p2
```

## 3. Labelliser les partitions (si deja partitionne)

Verifier les partitions existantes :

```bash
lsblk -f
blkid
```

Si les labels manquent :

```bash
# Label la partition root ext4
e2label /dev/nvme0n1pX nixos

# Label la partition boot FAT32
fatlabel /dev/nvme0n1pY boot
```

## 4. Monter et generer la config hardware

```bash
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# Generer le vrai hardware-configuration.nix
nixos-generate-config --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
```

> **IMPORTANT** : noter le contenu genere, il faudra le copier dans le repo.

## 5. Cloner le repo et preparer l'installation

```bash
nix-env -iA nixos.git

# Cloner dans le home du futur utilisateur
mkdir -p /mnt/home/<username>
git clone https://github.com/<ton-user>/dotfiles /mnt/home/<username>/dotfiles
cd /mnt/home/<username>/dotfiles
```

### Mettre a jour hardware-configuration.nix

Copier le contenu genere a l'etape 4 dans `hardware-configuration.nix` du repo.
Garder la section bootloader (systemd-boot) :

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```

### Creer secrets.nix

```bash
cp secrets.nix.example secrets.nix
nano secrets.nix
```

Remplir au minimum :
- `username`
- `email`
- `nixosDesktopMachineName`
- `sshKeys` (laisser `[]` si pas de cles)

### Rendre les fichiers non-tracked visibles au flake

```bash
git add -N secrets.nix
```

## 6. Creer le symlink pour nixPath

Le build evalue `nixPath` qui pointe vers `/home/<username>/dotfiles`, mais pendant l'installation les fichiers sont sous `/mnt`. Il faut creer un symlink :

```bash
sudo mkdir -p /home/<username>
sudo ln -s /mnt/home/<username>/dotfiles /home/<username>/dotfiles
```

## 7. Installer

```bash
sudo nixos-install --flake .#<nixosDesktopMachineName> --impure
```

Une fois `installation finished` affiche :

```bash
reboot
```

> Retirer la cle USB avant le reboot.

## 8. Post-installation

Apres le reboot, greetd s'affiche. Se connecter, Hyprland demarre.

Pour les mises a jour suivantes :

```bash
cd ~/dotfiles
git pull
sudo nixos-rebuild switch --flake .#<nixosDesktopMachineName> --impure
```

---

## Troubleshooting

### "Timed out waiting for device /dev/disk/by-uuid/..." au boot

**Cause** : les UUIDs dans `hardware-configuration.nix` ne correspondent pas aux vrais UUIDs des partitions.

**Solution** : boot sur l'ISO, verifier avec `blkid`, corriger les UUIDs dans `hardware-configuration.nix`.

### "You must set the option boot.loader.grub.devices"

**Cause** : GRUB est active mais mal configure (souvent apres un `nixos-generate-config` qui ecrase la config).

**Solution** : utiliser systemd-boot au lieu de GRUB :

```nix
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```

### "path /home/.../pkgs does not exist"

**Cause** : pendant l'installation, `nixPath` pointe vers `/home/<user>/dotfiles` mais les fichiers sont sous `/mnt/home/<user>/dotfiles`.

**Solution** :

```bash
sudo mkdir -p /home/<username>
sudo ln -s /mnt/home/<username>/dotfiles /home/<username>/dotfiles
```

### "undefined variable zen-browser" ou "attribute ... missing"

**Cause** : un input flake n'est pas passe dans `specialArgs` et/ou `home-manager.extraSpecialArgs`.

**Solution** : s'assurer que l'input est declare dans :
1. `flake.nix` → `inputs`
2. `flake.nix` → `outputs` arguments
3. `flake.nix` → `specialArgs` de la nixosConfiguration
4. `nixos-configuration.nix` → arguments du module
5. `nixos-configuration.nix` → `home-manager.extraSpecialArgs`
6. `home-manager/home.nix` → arguments du module

### "parse error near &&" au lancement de zsh

**Cause** : un alias genere une chaine vide (ex: `sshk` quand `secrets.sshKeys` est `[]`).

**Solution** : verifier que les alias dynamiques gèrent le cas vide dans `home-manager/shell/aliases.nix`.

### "windowrulev2 is deprecated" dans Hyprland

**Cause** : Hyprland a renomme `windowrulev2` en `windowrule`.

**Solution** : dans `home-manager/programs/hyprland.nix`, remplacer `windowrulev2` par `windowrule` et utiliser la nouvelle syntaxe :

```nix
# Ancien
windowrulev2 = [ "workspace 1, class:^(Slack)$" ];

# Nouveau
windowrule = [ "workspace 1, class:Slack" ];
```

### Pas d'interaction clavier/souris dans Hyprland

**Cause** : `libinput` n'est pas active.

**Solution** : ajouter dans `nixos-configuration.nix` :

```nix
services.libinput.enable = true;
```
