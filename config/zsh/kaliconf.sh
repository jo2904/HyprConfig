# ~/.zshrc - Zsh simple et efficace

#### --- VARIABLES D'ENVIRONNEMENT --- ####
export EDITOR=codium
export GPG_TTY=$(tty)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

HISTFILE="$XDG_CACHE_HOME/zsh/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000


#### --- OPTIONS ZSH --- ####
setopt autocd                 # entrer dans un dossier en tapant son nom
setopt correct                # corrige automatiquement les fautes de frappe
setopt interactivecomments    # autorise les commentaires interactifs
setopt auto_menu              # affiche automatiquement le menu de complétion
setopt complete_in_word       # complète aussi au milieu d’un mot
setopt no_beep                # désactive le bip
setopt prompt_subst           # substitutions dans le prompt
setopt extended_glob          # globbing avancé
setopt nomatch                # pas d’erreur si aucun match
setopt hist_ignore_dups       # ignore doublons
setopt hist_ignore_space      # ignore commandes commençant par espace
setopt hist_reduce_blanks     # supprime espaces inutiles
setopt share_history          # partage l’historique entre sessions
setopt inc_append_history     # ajoute immédiatement l’historique

WORDCHARS='_-'                # caractères considérés partie d’un mot


#### --- COMPLETION --- ####
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Styles de complétion
zstyle ':completion:*' menu select
zstyle ':completion:*' auto-description 'Spécifiez : %d'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' verbose true
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion::complete:*' use-cache yes

#### --- AUTO-SUGGESTIONS --- ####
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#777'
fi

#### --- SYNTAX HIGHLIGHTING --- ####
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#### --- PROMPT --- ####
autoload -U colors && colors
PROMPT_SYMBOL="❯"

PROMPT='%F{cyan}%n%f@%F{blue}%m%f:%F{blue}%~%f %F{yellow}${PROMPT_SYMBOL}%f '

# Variante pour root
if [[ $EUID -eq 0 ]]; then
  PROMPT='%F{red}⚡ root%f:%F{blue}%~%f %F{red}#%f '
fi

#### --- TITRE DU TERMINAL --- ####
case "$TERM" in
  xterm*|rxvt*|alacritty|gnome*)
    precmd() { print -Pn "\e]0;%n@%m: %~\a" }
  ;;
esac

#### --- RACCOURCIS CLAVIER (bindkey) --- ####
bindkey -e  # mode emacs

# Déplacements
bindkey '^[[1;5D' backward-word        # Ctrl + ←
bindkey '^[[1;5C' forward-word         # Ctrl + →
bindkey '^[[H' beginning-of-line       # Home
bindkey '^[[F' end-of-line             # End
bindkey '^A' beginning-of-line         # Ctrl + A
bindkey '^E' end-of-line               # Ctrl + E

# Suppression
bindkey '^[[3~' delete-char             # Suppr
bindkey '^H' backward-delete-char       # Backspace
bindkey '^W' backward-kill-word         # Ctrl + W
bindkey '^[[3;5~' kill-word             # Ctrl + Suppr
bindkey '^U' backward-kill-line         # Ctrl + U
bindkey '^K' kill-line                  # Ctrl + K

# Historique
bindkey '^P' up-history                 # Ctrl + P
bindkey '^N' down-history               # Ctrl + N
bindkey '^R' history-incremental-search-backward # Ctrl + R

# Autres pratiques
bindkey '^L' clear-screen               # Ctrl + L

#### --- ZLE & HIGHLIGHT --- ####
zle_highlight=('paste:none')  # pas de surlignage pour le texte collé
