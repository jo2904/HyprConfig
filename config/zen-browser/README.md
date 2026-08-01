# Zen Browser — config versionnée

Ce dossier contient la partie de la config Zen Browser qu'on veut la même
sur toutes les machines (PC fixe, laptop), versionnée et liée par symlink
dans le vrai profil Zen — voir `config/scripts/link-zen-config.sh`.

## Pourquoi pas juste synchroniser le profil entier (Nextcloud, etc.) ?

Le profil Zen (`~/.config/zen/<hash>.Default (release)/`) contient surtout
des bases SQLite (`places.sqlite`, `cookies.sqlite`, `logins.db`...) et des
fichiers de session (`zen-sessions.jsonlz4`) réécrits en continu pendant que
le navigateur tourne, avec des `.wal`/`.parentlock`. Un outil de sync par
fichiers (Nextcloud, Dropbox...) qui upload/download pendant ces écritures
corrompt le profil — on en a la preuve dans ce profil même : une pile de
`zen-sessions.jsonlz4-*.corrupt` accumulée au fil des crashs normaux, sans
qu'aucune sync ne soit même en cause. Ajouter un écrivain concurrent
là-dessus ne peut qu'empirer les choses.

Le Sync intégré de Zen (compte Mozilla) est le bon outil pour bookmarks,
mots de passe, historique, onglets ouverts et liste d'extensions — mais il
ne touche pas aux réglages propres à Zen (mods, thèmes, raccourcis).

## Ce qui est synchronisé ici (et pourquoi c'est sûr)

Contrairement aux fichiers ci-dessus, ces fichiers ne sont réécrits que
quand on change un réglage dans l'UI Zen (installer un mod, changer un
raccourci) — jamais en continu pendant la navigation. Un seul écrivain à la
fois, donc sûr à versionner/symlink :

- `chrome/` — dossier de personnalisation Zen :
  - `zen-themes.css` : CSS agrégé généré par Zen à partir des mods
    installés (fichier `DO NOT EDIT` — ne pas modifier à la main).
  - `zen-themes/<uuid>/` : fichiers téléchargés de chaque mod (cache local).
  - `userChrome.css` / `userContent.css` : si un jour on personnalise
    l'UI à la main, ça vit ici aussi.
- `zen-themes.json` — liste des mods installés (source de vérité : id,
  version, activé/désactivé). C'est ce fichier que Zen relit pour
  régénérer `chrome/zen-themes.css` et `chrome/zen-themes/`.
- `zen-keyboard-shortcuts.json` — raccourcis clavier personnalisés.

## Ce qui n'est PAS synchronisé (volontairement)

- Tout le reste du profil : `places.sqlite`, `cookies.sqlite`, `logins.db`,
  `prefs.js`, `zen-sessions.jsonlz4`, `storage/`, `extensions/`... Rien de
  tout ça n'est stable en écriture, et une bonne partie (mots de passe,
  cookies) n'a de toute façon rien à faire dans un repo git.
- Les préférences `about:config` générales : si on veut en fixer une
  précise à travers les machines, la méthode robuste est un `user.js`
  dans le profil (appliqué à chaque démarrage, sans toucher au fragile
  `prefs.js`) — pas encore mis en place ici, à ajouter si besoin.

## Comment ça marche

`config/scripts/link-zen-config.sh` :

1. Lit `~/.config/zen/installs.ini` pour trouver le nom réel du dossier de
   profil sur *cette* machine (c'est un hash aléatoire par installation,
   différent sur chaque PC — jamais codé en dur).
2. Pour chaque item ci-dessus : si le repo ne l'a pas encore (première
   machine), le déplace du profil vers le repo puis crée le symlink
   retour. Sinon, sauvegarde tout fichier réel préexistant et symlink
   depuis le repo — idempotent, comme `link-config.sh`.

Appelé automatiquement par `install-env.sh` et `update.sh`. Pour relier une
nouvelle machine sans réinstaller : lancer Zen Browser une première fois
(pour qu'il crée son profil), puis `./update.sh`.

Pour forcer Zen à régénérer `chrome/zen-themes.css` après avoir tiré des
changements de `zen-themes.json` sur une autre machine, relancer Zen
suffit — il relit l'état des mods au démarrage.
