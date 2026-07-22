# HyprConfig

Dotfiles pour un environnement Hyprland : Hyprland (config Lua), hypridle,
hyprlock, hyprpaper, hyprsunset, Quickshell (+ module overview), Waybar,
Mako, Rofi, kitty, yazi, btop, fastfetch, zsh, et un thème SDDM.

## Structure

- `config/` — tout ce qui est lié dans `~/.config/<app>` (un dossier par
  appli).
- `install-env.sh` — installation complète sur une machine neuve.
- `update.sh` — mise à jour légère (à lancer régulièrement).
- `link-config.sh` — logique de symlink partagée par les deux scripts
  ci-dessus.
- `packages.sh` — liste des paquets pacman/yay pour la stack Hyprland.
- `theme-sddm.sh` — installation du thème SDDM + durcissement faillock/PAM.
- `defaultApp.sh` — associations d'applications par défaut (xdg-mime).
- `install-arch.sh` — installeur Arch complet (LUKS2 + Btrfs + systemd-boot),
  à lancer depuis l'ISO live, avant même que l'OS existe. Sans rapport avec
  le déploiement de la config.

## Modèle de déploiement : symlinks

Chaque sous-dossier de `config/` est lié dans `~/.config/` par un lien
symbolique (`~/.config/hypr` -> `<repo>/config/hypr`, etc.), pas copié.
Conséquence : modifier un fichier directement dans `~/.config/hypr/...`
modifie littéralement le fichier du repo. Il n'y a plus de synchronisation
manuelle à faire — juste committer et pousser quand on veut versionner.

Si un dossier existe déjà réellement dans `~/.config` (pas un lien) au
moment de la liaison, il est renommé en `<dossier>.bak-<date>` avant la
création du lien : rien n'est perdu.

## Installation (machine neuve)

```bash
./install-env.sh
```

Installe les paquets, lie toute la config, configure les associations
d'applications par défaut, le thème SDDM, le durcissement faillock/PAM, la
touche d'alimentation, active SDDM, et demande l'identité git si elle n'est
pas déjà configurée. Le script est idempotent : le relancer ne duplique
rien (pas de doublon dans `.zshrc`, les liens déjà corrects sont laissés
tels quels).

## Mise à jour

```bash
./update.sh
```

Fait un `git pull`, réapplique les symlinks (utile si de nouvelles apps ont
été ajoutées au repo depuis la dernière fois) et remet à jour les
permissions d'exécution des scripts. Ne touche ni aux paquets, ni à SDDM, ni
à systemd — pas besoin de `sudo`.

## Ajouter la config d'une nouvelle appli

1. Créer `config/<app>/` dans le repo avec les fichiers voulus.
2. Committer.
3. Sur chaque machine : `./update.sh` (ou `./install-env.sh` sur une
   machine neuve) crée automatiquement le lien `~/.config/<app>`.
