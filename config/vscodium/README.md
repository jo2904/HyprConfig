# VSCodium — config versionnée

Ce dossier contient la partie du profil VSCodium qu'on veut la même sur
toutes les machines (PC fixe, laptop), versionnée et liée par symlink dans
le vrai profil VSCodium — voir `config/scripts/link-vscodium-config.sh`.

## Pourquoi pas juste lier tout `~/.config/VSCodium` ?

`~/.config/VSCodium/` contient surtout du cache et de l'état de session
réécrits en continu pendant que l'éditeur tourne : `Cache/`, `Code Cache/`,
`GPUCache/`, `Local Storage/`, `Session Storage/`, `blob_storage/`,
`Crashpad/`, `Cookies`, `Preferences`, `Local State`, et dans `User/` :
`globalStorage/`, `History/`, `workspaceStorage/`. Même logique que pour
Zen Browser (voir `config/zen-browser/README.md`) : versionner/symlink ça
ne peut que causer des corruptions ou des divergences inutiles entre
machines.

## Ce qui est synchronisé ici (et pourquoi c'est sûr)

Ces fichiers ne sont réécrits que quand on change un réglage dans l'UI
(paramètres, raccourcis, snippets) — jamais en continu :

- `User/settings.json` — préférences de l'éditeur.
- `User/keybindings.json` — raccourcis clavier personnalisés.
- `User/snippets/` — snippets personnalisés.

## Extensions

`extensions.txt` liste les ids d'extensions (une par ligne, format
`editeur.nom`, obtenu via `codium --list-extensions`). Les extensions
elles-mêmes (code, binaires) ne sont pas versionnées — trop lourd et
spécifique à la machine (build natif, cache). `link-vscodium-config.sh`
installe celles qui manquent via `codium --install-extension` à chaque
`update.sh` ; c'est additif, une extension installée en plus sur une
machine n'est jamais désinstallée.

Pour ajouter une extension à toutes les machines : l'installer normalement
dans VSCodium, puis régénérer la liste :

```bash
codium --list-extensions > config/vscodium/extensions.txt
```

## Comment ça marche

`config/scripts/link-vscodium-config.sh` :

1. Pour chaque item ci-dessus : si le repo ne l'a pas encore (première
   machine), le déplace du profil vers le repo puis crée le symlink
   retour. Sinon, sauvegarde tout fichier réel préexistant et symlink
   depuis le repo — idempotent, comme `link-config.sh`.
2. Installe les extensions manquantes depuis `extensions.txt`.

Appelé automatiquement par `install-env.sh` et `update.sh`. Pour relier une
nouvelle machine sans réinstaller : lancer VSCodium une première fois (pour
qu'il crée son profil), puis `./update.sh`.
