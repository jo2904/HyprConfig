# Nextcloud — dossiers synchronisés par défaut

`nextcloud.cfg.template` définit les 4 dossiers à synchroniser par défaut
(Documents, divers, Images, Téléchargements) pour le compte
`https://trystop.eu`. Pas de secret dedans : l'auth utilise le flow
navigateur (`authType=webflow`), le token vit dans le trousseau système
(kwallet/gnome-keyring), jamais dans ce fichier.

`Nextcloud.desktop` est l'entrée XDG autostart (`~/.config/autostart/`) qui
fait démarrer le client au boot — c'est un fichier séparé de
`nextcloud.cfg`, pas créé par le paquet, généré par le client seulement
quand on coche "Lancer au démarrage" dans ses réglages. Sans le seeder
aussi, le client ne démarrerait pas tout seul après un reboot tant que
personne n'a coché la case à la main.

## Pourquoi un template, pas un symlink

`~/.config/Nextcloud/nextcloud.cfg` est réécrit par le client à chaque
lancement/fermeture (taille de fenêtre, version du client, état de sync...).
Le symlinker comme le reste des dotfiles polluerait le repo en continu.
`config/scripts/setup-nextcloud.sh` copie donc le template **une seule
fois**, avant la toute première connexion sur une machine neuve — après
ça le fichier réel vit sa vie et n'est plus touché par le repo.

## Utilisation

Appelé automatiquement par `install-env.sh` (pas `update.sh` : c'est du
provisioning une-fois, pas de la config à garder synchronisée en continu,
même logique que le thème SDDM ou le hardening PAM).

Sur une machine déjà configurée, le script ne fait rien (`nextcloud.cfg`
existe déjà — l'autostart n'est alors pas retouché non plus). Pour
reseeder depuis le template : supprimer `~/.config/Nextcloud/nextcloud.cfg`
puis relancer le script.

Après le seed : lancer Nextcloud, se connecter (webflow/OAuth dans le
navigateur) — les 4 dossiers sont déjà déclarés, pas besoin de repasser
par l'assistant "ajouter un dossier" un par un.
